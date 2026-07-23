{ pkgs, ... }:
{
  programs.k9s = {
    enable = true;
    package = pkgs.unstable.k9s;

    settings.k9s = {
      liveViewAutoRefresh = false;
      refreshRate = 2;
      maxConnRetry = 5;
      disablePodCounting = true;
      skipLatestRevCheck = true;

      ui = {
        headless = true;
        logoless = true;
        crumbsless = false;
        reactive = false;
        skin = "minimal";
      };

      logger = {
        tail = 200;
        buffer = 1000;
        sinceSeconds = -1;
      };
    };

    skins.minimal.k9s = {
      body = {
        fgColor = "default";
        bgColor = "default";
        logoColor = "#cba6f7";
      };
      prompt = {
        fgColor = "default";
        bgColor = "default";
        suggestColor = "#cba6f7";
      };
      info = {
        fgColor = "#cba6f7";
        sectionColor = "default";
      };
      frame = {
        border = {
          fgColor = "#585b70";
          focusColor = "#cba6f7";
        };
        menu = {
          fgColor = "default";
          keyColor = "#cba6f7";
          numKeyColor = "#cba6f7";
        };
        crumbs = {
          fgColor = "default";
          bgColor = "default";
          activeColor = "#cba6f7";
        };
        status = {
          newColor = "#89b4fa";
          modifyColor = "#cba6f7";
          addColor = "#a6e3a1";
          errorColor = "#f38ba8";
          highlightColor = "#f9e2af";
          killColor = "#6c7086";
          completedColor = "#6c7086";
        };
        title = {
          fgColor = "default";
          bgColor = "default";
          highlightColor = "#f9e2af";
          counterColor = "#cba6f7";
          filterColor = "#cba6f7";
        };
      };
      views = {
        table = {
          fgColor = "default";
          bgColor = "default";
          cursorFgColor = "#11111b";
          cursorBgColor = "#cba6f7";
          header = {
            fgColor = "#cba6f7";
            bgColor = "default";
            sorterColor = "#89b4fa";
          };
        };
      };
    };

    views = {
      "v1/pods".columns = [
        "NAME"
        "READY"
        "STATUS"
        "RESTARTS"
        "CPU"
        "MEM"
        "AGE"
      ];
      "apps/v1/deployments".columns = [
        "NAME"
        "READY"
        "UP-TO-DATE"
        "AVAILABLE"
        "AGE"
      ];
      "v1/services".columns = [
        "NAME"
        "TYPE"
        "CLUSTER-IP"
        "PORTS"
        "AGE"
      ];
    };
  };
}
