let
  # Flattens an attribute set representing a file tree and turns it into a dot-separated key-value attribute set for
  # each file
  #
  # Example:
  #   { foo = { bar = { biz = biz.nix; }; }; } -> { "foo.bar.biz" = biz.nix; }
  #
  # Type:
  #   tree :: { [ name :: string ] :: ( leaf :: (T | ( branch :: ( leaf | tree )))), ... } -> { string -> leaf }
  flattenTree = tree:
    let
      inherit (builtins) concatStringsSep isPath isAttrs foldl' attrNames;

      # Takes an accumulator attribute set, a path in the form of a list of strings, and a value of what is at that
      # path (either an attribute set, meaning a subdirectory; a path, meaning it's a file; or nothing, meaning it's an
      # empty directory). Will turn the path into a dot-separated string (`foo/bar/biz` turns into `foo.bar.biz`) and
      # will recurse over the subdirectory if it's an attribute set, add to our accumulator if it's a file, or just
      # return the accumulator if it's neither
      flatten = acc: path: leaf:
        # If the value is a path, then format the path as a dot-separated string and add this path and value to the
        if isPath leaf then
          (acc // { "${concatStringsSep "." path}" = leaf; })
          # If the value is a set of attributes, this means there is a subtree -- run again for those attributes
        else if isAttrs leaf then
          (recurse acc path leaf)
          # If it's not a value or a path (meaning null), just return the accumulated results without doing anything
        else
          acc;

      # Calls `flatten` recusively, accumulating a set of attributes as we go. As we recurse, we build up the path in a
      # list to eventually return as the dot-separated string and call `lfatten` on that path and node
      # recurse = acc: path: tree:
      #   # Operation being called by `foldl'` -- takes an accumulator, the leaf we're currently analyzing, and calls
      #   # `flatten` against that path and leaf
      #   let op = acc: leaf: (flatten (acc (path ++ [ leaf ]) tree.${leaf}));
      #   in foldl' (op acc (attrNames tree));
      recurse = acc: path: leaf:
        foldl' (acc: key: flatten acc (path ++ [ key ]) leaf.${key}) acc
        (attrNames leaf);

      # Call `recurse`, starting with an empty accumulator, an empty path, and a tree to run the function against
    in recurse { } [ ] tree;
in { inherit flattenTree; }
