{ _lib, self }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.rift;
  tomlFormat = pkgs.formats.toml { };
in

{
  options = {
    programs.rift = {
      enable = lib.mkEnableOption "rift, a tiling window manager for macos";

      package = lib.mkPackageOption self.packages.${pkgs.stdenv.hostPlatform.system} "rift" { };

      keys = lib.mkOption {
        default = { };
        description = ''
          Key binding configuration. Define keyboard shortcuts to control rift. Keys are strings like
          "Alt + H" and values are either command strings or attribute sets with command parameters.
        '';
        type = with lib.types; attrsOf (either str (attrsOf anything));
        example = lib.literalExpression ''
          {
            "Alt + H" = {
              move_focus = "left";
            };
            "Alt + J" = {
              move_focus = "down";
            };
            "Alt + Z" = "toggle_space_activated";
            "Alt + 1" = {
              switch_to_workspace = 1;
            };
          }
        '';
      };

      settings = lib.mkOption {
        default = { };
        description = "Configuration options for rift";
        type = lib.types.submodule {
          options = {
            animate = lib.mkOption {
              default = true;
              description = "Master switch for all window animations.";
              type = lib.types.bool;
            };

            animationDuration = lib.mkOption {
              default = 0.3;
              description = "Duration of animations in seconds. Typical values: 0.15–0.35.";
              type = lib.types.float;
            };

            animationEasing = lib.mkOption {
              default = "ease_in_out";
              description = "Easing curve for animations.";
              example = "ease_in_out_sine";
              type = lib.types.enum [
                "ease_in_circ"
                "ease_in_cubic"
                "ease_in_expo"
                "ease_in_out"
                "ease_in_out_circ"
                "ease_in_out_cubic"
                "ease_in_out_expo"
                "ease_in_out_quad"
                "ease_in_out_quart"
                "ease_in_out_quint"
                "ease_in_out_sine"
                "ease_in_quad"
                "ease_in_quart"
                "ease_in_quint"
                "ease_in_sine"
                "ease_out_circ"
                "ease_out_cubic"
                "ease_out_expo"
                "ease_out_quad"
                "ease_out_quart"
                "ease_out_quint"
                "ease_out_sine"
                "linear"
              ];
            };

            animationFps = lib.mkOption {
              default = 100;
              description = "Frames per second for animations. 60–120 recommended.";
              example = 60;
              type = lib.types.int;
            };

            autoFocusBlacklist = lib.mkOption {
              default = [ ];
              description = ''
                List of bundle identifiers of applications to prevent from stealing focus or causing workspace
                switches. Invalid bundle identifiers will be silently ignored.
              '';
              example = [
                "com.apple.dock"
                "com.raycast.macos"
                "com.apple.Spotlight"
              ];
              type = with lib.types; listOf str;
            };

            focusFollowsMouse = lib.mkOption {
              default = true;
              description = "Moving the mouse into a window focuses it.";
              type = lib.types.bool;
            };

            gestures = lib.mkOption {
              default = { };
              type = lib.types.submodule {
                options = {
                  distancePct = lib.mkOption {
                    default = 0.08;
                    description = "Normalized horizontal distance (0..1) to trigger swipe for NSTouch-based detection.";
                    example = 0.12;
                    type = lib.types.float;
                  };

                  enabled = lib.mkOption {
                    default = false;
                    description = "Enable horizontal swipes to switch virtual workspaces.";
                    type = lib.types.bool;
                  };

                  fingers = lib.mkOption {
                    default = 3;
                    description = "Number of fingers required for swipe gesture.";
                    example = 4;
                    type = lib.types.int;
                  };

                  hapticPattern = lib.mkOption {
                    default = "level_change";
                    description = "Haptic feedback pattern to use.";
                    example = "alignment";
                    type = lib.types.enum [
                      "generic"
                      "alignment"
                      "level_change"
                    ];
                  };

                  hapticsEnabled = lib.mkOption {
                    default = true;
                    description = "Enable haptic feedback on commit.";
                    type = lib.types.bool;
                  };

                  invertHorizontalSwipe = lib.mkOption {
                    default = false;
                    description = "Invert horizontal direction (swap next/prev).";
                    type = lib.types.bool;
                  };

                  skipEmpty = lib.mkOption {
                    default = true;
                    description = "Skip empty workspaces when swiping.";
                    type = lib.types.bool;
                  };

                  swipeVerticalTolerance = lib.mkOption {
                    default = 0.4;
                    description = ''
                      Maximum vertical travel allowed for the horizontal swipe to register. Accepts normalized fraction
                      (float value between 0 and 1) or percentage.
                    '';
                    example = 40;
                    type = with lib.types; either (numbers.between 0 1) (ints.between 0 100);
                  };
                };
              };
            };

            layout = lib.mkOption {
              default = { };
              type = lib.types.submodule {
                options = {
                  gaps = lib.mkOption {
                    default = { };
                    type = lib.types.submodule {
                      options = {
                        inner = lib.mkOption {
                          default = { };
                          type = lib.types.submodule {
                            options = {
                              horizontal = lib.mkOption {
                                default = 0;
                                description = "Horizontal gap between tiled windows in pixels.";
                                type = lib.types.int;
                              };

                              vertical = lib.mkOption {
                                default = 0;
                                description = "Vertical gap between tiled windows in pixels.";
                                type = lib.types.int;
                              };
                            };
                          };
                        };

                        outer = lib.mkOption {
                          default = { };
                          type = lib.types.submodule {
                            options = {
                              bottom = lib.mkOption {
                                default = 0;
                                description = "Gap between windows and bottom screen edge in pixels.";
                                type = lib.types.int;
                              };

                              left = lib.mkOption {
                                default = 0;
                                description = "Gap between windows and left screen edge in pixels.";
                                type = lib.types.int;
                              };

                              right = lib.mkOption {
                                default = 0;
                                description = "Gap between windows and right screen edge in pixels.";
                                type = lib.types.int;
                              };

                              top = lib.mkOption {
                                default = 0;
                                description = "Gap between windows and top screen edge in pixels.";
                                type = lib.types.int;
                              };
                            };
                          };
                        };
                      };
                    };
                  };

                  mode = lib.mkOption {
                    default = "traditional";
                    description = ''
                      Layout system mode.
                        - traditional: i3/sway-like containers
                        - bsp: binary space partitioning
                    '';
                    example = "bsp";
                    type = lib.types.enum [
                      "traditional"
                      "bsp"
                    ];
                  };

                  stack = lib.mkOption {
                    default = { };
                    type = lib.types.submodule {
                      options = {
                        defaultOrientation = lib.mkOption {
                          default = "perpendicular";
                          description = ''
                            Default stacking orientation when creating a new stack.
                              - perpendicular: orientation is perpendicular to parent layout
                              - same: orientation is the same as parent layout
                              - horizontal|vertical: explicit orientation
                          '';
                          example = "horizontal";
                          type = lib.types.enum [
                            "perpendicular"
                            "same"
                            "horizontal"
                            "vertical"
                          ];
                        };

                        stackOffset = lib.mkOption {
                          default = 40;
                          description = ''
                            Offset between stacked windows in pixels. Set to 0 to have them
                            directly on top of each other. Recommended: 30-50 for clear edges while
                            keeping focus visible.
                          '';
                          example = 50;
                          type = lib.types.int;
                        };
                      };
                    };
                  };
                };
              };
            };

            mouseFollowsFocus = lib.mkOption {
              default = true;
              description = "When focus changes, move the mouse to the focused window.";
              type = lib.types.bool;
            };

            mouseHidesOnFocus = lib.mkOption {
              default = true;
              description = "Hide the mouse cursor after focusing a window.";
              type = lib.types.bool;
            };

            runOnStart = lib.mkOption {
              default = [ ];
              description = ''
                Commands to run on rift startup. Can subscribe to rift events and trigger scripts.
                The command receives environment variables with context like RIFT_EVENT_TYPE,
                RIFT_WORKSPACE_ID, RIFT_WORKSPACE_NAME, etc.
              '';
              example = [
                "rift-cli subscribe cli --event workspace_changed --command sh --args -c --args 'echo $RIFT_WORKSPACE_NAME'"
              ];
              type = with lib.types; listOf str;
            };

            ui = lib.mkOption {
              default = { };
              type = lib.types.submodule {
                options = {
                  menuBar = lib.mkOption {
                    default = { };
                    type = lib.types.submodule {
                      options = {
                        enabled = lib.mkOption {
                          default = false;
                          description = "Whether to enable menu bar workspace indicators.";
                          type = lib.types.bool;
                        };

                        showEmpty = lib.mkOption {
                          default = false;
                          description = ''
                            If enabled, show all workspaces including empty ones. Disabled by default as it tends to take up too
                            much room in the menubar.
                          '';
                          type = lib.types.bool;
                        };
                      };
                    };
                  };

                  missionControl = lib.mkOption {
                    default = { };
                    type = lib.types.submodule {
                      options = {
                        enabled = lib.mkOption {
                          default = false;
                          description = "Whether to enable experimental mission control feature.";
                          type = lib.types.bool;
                        };

                        fadeDurationMs = lib.mkOption {
                          default = 180;
                          description = "Fade duration in milliseconds. Native macOS mission control fade is about 180ms.";
                          example = 200;
                          type = lib.types.int;
                        };

                        fadeEnabled = lib.mkOption {
                          default = false;
                          description = "Enable fade animation when entering/exiting mission control.";
                          type = lib.types.bool;
                        };
                      };
                    };
                  };

                  stackLine = lib.mkOption {
                    default = { };
                    type = lib.types.submodule {
                      options = {
                        enabled = lib.mkOption {
                          default = false;
                          description = "Enable experimental stack line indicator.";
                          type = lib.types.bool;
                        };

                        horizPlacement = lib.mkOption {
                          default = "top";
                          description = "In a horizontal stack, where the line will be (top/bottom).";
                          example = "bottom";
                          type = lib.types.enum [
                            "top"
                            "bottom"
                          ];
                        };

                        spacing = lib.mkOption {
                          default = 0;
                          description = "Spacing between the stack line and window edges in pixels.";
                          example = 2;
                          type = lib.types.int;
                        };

                        thickness = lib.mkOption {
                          default = 0;
                          description = "How thick the line indicator will be in pixels.";
                          example = 4;
                          type = lib.types.int;
                        };

                        vertPlacement = lib.mkOption {
                          default = "left";
                          description = "In a vertical stack, where the line will be (left/right).";
                          example = "right";
                          type = lib.types.enum [
                            "left"
                            "right"
                          ];
                        };
                      };
                    };
                  };
                };
              };
            };

            windowSnapping = lib.mkOption {
              default = { };
              type = lib.types.submodule {
                options = {
                  dragSwapFraction = lib.mkOption {
                    default = 0.3;
                    description = ''
                      Fraction threshold (0.0..1.0) specifying how much of the dragged window
                      area must be overlapped by a candidate window to trigger a swap while dragging.
                      Typical values are around 0.2–0.4. Lower values = more aggressive swapping.
                    '';
                    example = 0.25;
                    type = lib.types.float;
                  };
                };
              };
            };
          };
        };
      };

      startAtLogin = lib.mkOption {
        default = true;
        description = "Whether to configure a launchd agent to auto-start rift at login";
        type = lib.types.bool;
      };

      virtualWorkspaces = lib.mkOption {
        default = { };
        description = "Virtual workspaces configuration";
        type = lib.types.submodule {
          options = {
            enabled = lib.mkOption {
              default = true;
              description = "Whether to enable virtual workspaces";
              type = lib.types.bool;
            };

            defaultWorkspaceCount = lib.mkOption {
              default = 4;
              description = "Number of workspaces to create on startup (1-32)";
              example = 6;
              type = lib.types.ints.between 1 32;
            };

            autoAssignWindows = lib.mkOption {
              default = true;
              description = "When true, new windows can be auto-assigned using appRules";
              type = lib.types.bool;
            };

            preserveFocusPerWorkspace = lib.mkOption {
              default = true;
              description = "Remember last focused window per workspace";
              type = lib.types.bool;
            };

            workspaceAutoBackAndForth = lib.mkOption {
              default = false;
              description = ''
                When enabled, if you try to switch to the same workspace that's already active, it
                will switch to the last workspace instead.
              '';
              type = lib.types.bool;
            };

            defaultWorkspace = lib.mkOption {
              default = 0;
              description = ''
                Default workspace to activate on startup (0-based index). Must be less than the value of
                defaultWorkspaceCount.
              '';
              example = 0;
              type = lib.types.ints.unsigned;
            };

            workspaceNames = lib.mkOption {
              default = [ ];
              description = ''
                Workspace names (indexed order). If fewer than defaultWorkspaceCount are provided,
                remaining workspaces are named "Workspace X". Do not provide more names than
                the value of defaultWorkspaceCount.
              '';
              example = [
                "first"
                "second"
                "third"
              ];
              type = lib.types.listOf lib.types.str;
            };

            appRules = lib.mkOption {
              default = [ ];
              description = ''
                App rules for automatic window assignment. Define rules that match new windows and
                set properties (workspace, floating, etc).
              '';
              example = [
                {
                  app_id = "com.apple.Safari";
                  workspace = 1;
                }
                {
                  title_substring = "Preferences";
                  floating = true;
                }
              ];
              type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.agents.rift = {
      enable = cfg.startAtLogin;
      config = {
        EnvironmentVariables.RUST_LOG = "error,warn,info";
        KeepAlive.Crashed = true;
        KeepAlive.SuccessfulExit = false;
        Label = "git.acsandmann.rift";
        LimitLoadToSessionType = "Aqua";
        Nice = -20;
        ProcessType = "Interactive";
        ProgramArguments = [ (lib.getExe cfg.package) ];
        RunAtLoad = true;
        StandardErrorPath = "/tmp/rift.stderr.log";
        StandardOutPath = "/tmp/rift.stdout.log";
      };
    };

    home.packages = [ cfg.package ];

    xdg.configFile."rift/config.toml" = lib.mkIf (cfg.settings != { }) {
      # Generate the toml file from 'cfg.settings' and convert the attribute names back to snake_case
      source = tomlFormat.generate "rift-settings" (
        _lib.recursiveApply _lib.toSnakeCase { inherit (cfg) keys settings virtualWorkspaces; }
      );
    };
  };
}
