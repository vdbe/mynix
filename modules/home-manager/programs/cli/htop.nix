{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;
in
{
  options.mymodules.programs.cli.htop = { enable = mkBoolOpt false; };

  config = mkIf config.mymodules.programs.cli.htop.enable {
    programs.htop = {
      enable = true;

      settings =
        let
          inherit (config.lib.htop) bar fields leftMeters rightMeters text;
        in
        {
          enable_mouse = true;
          hide_kernel_threads = true;
          hide_userland_threads = true;
          highlight_base_name = true;
          highlight_megabytes = true;
          screen_tabs = true;
          show_program_path = false;
          show_thread_names = true;
          update_process_names = false;

          # Show the CPU frequency, temperature usage percentages in the CPU bars.
          show_cpu_frequency = true;
          show_cpu_temperature = true;
          show_cpu_usage = true;
          cpu_count_from_one = false;
          detailed_cpu_time = true;

          # By default when not in tree view, sort by the CPU usage.
          sort_direction = 0;
          sort_key = fields.PERCENT_CPU;

          # By default when in tree view, sort by PID.
          tree_view = false;
          tree_sort_direction = 1;
          tree_sort_key = fields.PID;
          tree_view_always_by_pid = false;

          # The fields in the htop table.
          fields = with config.lib.htop.fields; [
            PID
            USER
            NICE
            IO_PRIORITY
            M_SIZE
            M_RESIDENT
            M_SHARE
            STATE
            PERCENT_CPU
            PERCENT_MEM
            TIME
            STARTTIME
            COMM
          ];

          # TODO: Add I/O tab

        } // (leftMeters [
          #(bar "AllCPUs2")
          #(bar "CPU")
          (bar "AllCPUs")
          (bar "Memory")
          (bar "Swap")
        ]) // (rightMeters [
          (text "Tasks")
          (text "LoadAverage")
          (text "DiskIO")
          (text "NetworkIO")
          (text "Uptime")
        ]);
    };
  };
}
