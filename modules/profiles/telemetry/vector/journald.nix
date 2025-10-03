{ lib, ... }: {
  services.vector = {
    journaldAccess = true;

    settings = {
      sources.journald.type = "journald";

      transforms = {
        filter_journald = {
          type = "filter";
          inputs = [ "journald" ];
          condition = ''
            !contains(string!(.message), "Node Status Update Result")
          '';
        };

        parse_journald = {
          type = "remap";
          inputs = [ "filter_journald" ];
          # TODO: Properly parse vector/thanos logs
          source = ''
            priority = to_int(.PRIORITY) ?? 6

            unit = .UNIT || .USER_UNIT || ._SYSTEMD_UNIT || .SYSLOG_IDENTIFIER

            if unit != null && match(string!(unit), r'^session-\d+\.scope$') {
              unit = "session.scope"
            }

            if unit != null && match(string!(unit), r'^systemd-session-\d+\.scope$') {
              unit = "systemd-session.scope"
            }

            labels = {
              "unit": unit,
              "priority": priority,
              "level": to_syslog_level(priority) ?? "info",
              "host": .host,
              "application": "journald"
            }

            .message = .message
            .timestamp = .timestamp
            .labels = labels

            del(.__MONOTONIC_TIMESTAMP)
            del(.__REALTIME_TIMESTAMP)
            del(.__SEQNUM_ID)
            del(.__SEQNUM)
            del(._AUDIT_LOGINUID)
            del(._AUDIT_SESSION)
            del(._BOOT_ID)
            del(._CAP_EFFECTIVE)
            del(._CMDLINE)
            del(._COMM)
            del(._EXE)
            del(._GID)
            del(._MACHINE_ID)
            del(._PID)
            del(._RUNTIME_SCOPE)
            del(._SELINUX_CONTEXT)
            del(._SOURCE_MONOTONIC_TIMESTAMP)
            del(._SOURCE_REALTIME_TIMESTAMP)
            del(._STREAM_ID)
            del(._SYSTEMD_CGROUP)
            del(._SYSTEMD_INVOCATION_ID)
            del(._SYSTEMD_OWNER_UID)
            del(._SYSTEMD_SESSION)
            del(._SYSTEMD_SLICE)
            del(._SYSTEMD_UNIT)
            del(._SYSTEMD_USER_SLICE)
            del(._TRANSPORT)
            del(._UID)
            del(.CODE_FILE)
            del(.CODE_FUNC)
            del(.CODE_LINE)
            del(.CONTAINER_ID_FULL)
            del(.CONTAINER_ID)
            del(.CONTAINER_LOG_EPOCH)
            del(.CONTAINER_LOG_ORDINAL)
            del(.CONTAINER_NAME)
            del(.CONTAINER_TAG)
            del(.host)
            del(.host)
            del(.IMAGE_NAME)
            del(.INVOCATION_ID)
            del(.JOB_ID)
            del(.JOB_RESULT)
            del(.JOB_TYPE)
            del(.LEADER)
            del(.MESSAGE_ID)
            del(.PRIORITY)
            del(.SESSION_ID)
            del(.source_type)
            del(.SYSLOG_FACILITY)
            del(.SYSLOG_IDENTIFIER)
            del(.SYSLOG_PID)
            del(.SYSLOG_TIMESTAMP)
            del(.TID)
            del(.UNIT)
            del(.USER_ID)
            del(.USER_UNIT)
          '';
        };
      };

      sinks.loki.inputs = lib.mkAfter [ "parse_journald" ];
    };
  };
}
