let
  flattenTree = tree:
    let
      op = sum: path: val:
        let pathStr = builtins.concatStringsSep "." path;
        in if builtins.isPath val then
          (sum // { "${pathStr}" = val; })
        else if builtins.isAttrs val then
          (recurse sum path val)
        else
          sum;

      recurse = sum: path: val:
        builtins.foldl' (sum: key: op sum (path ++ [ key ]) val.${key}) sum
        (builtins.attrNames val);
    in recurse { } [ ] tree;
in { inherit flattenTree; }
