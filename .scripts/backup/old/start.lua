-- Just a simple script to backup my personal files
-- Windows only!


-- =============
-- ARGS OPTIONS
-- =============
-- --copy-only is used to only run
--             proc_copy_data_to_bck_dir()
-- --zip-only is used to only run
--             proc_copy_data_to_bck_dir()
--             proc_7z_bck_dir()

-- =============
-- CONFIG
-- =============
SIZE_LIMIT_WEEKLY = 10737418240 -- 10GB
TEMP_FOLDER_PATH_WEEKLY = "weekly"
CLOUD_PATH_WEEKLY = "drive_weekly:"

SIZE_LIMIT_DAILY =  1073741824 -- 1GB
TEMP_FOLDER_PATH_DAILY = "daily"
CLOUD_PATH_DAILY = "drive_daily:"

C_PATH = "c:\\"
D_PATH = "d:\\"

WEEKLY = {
  ["keepass"] = {
    fmt_name = "KeePass",
    path = C_PATH .. "ohno\\",
    dir_name = "keepass"
  },
  ["notes"] = {
    fmt_name = "Notes",
    path = C_PATH .. "ohno\\",
    dir_name = "notes"
  },
  ["uff"] = {
    fmt_name = "Uff",
    path = C_PATH .. "ohno\\",
    dir_name = "uff"
  },
  ["photos"] = {
    fmt_name = "Fotos",
    path = D_PATH .. "backups\\",
    dir_name = "fotos"
  },
  ["docs"] = {
    fmt_name = "Documentos",
    path = D_PATH .. "backups\\",
    dir_name = "documentos"
  },
  ["games"] = {
    fmt_name = "Jogos",
    path = D_PATH .. "backups\\",
    dir_name = "jogos"
  },
  ["books"] = {
    fmt_name = "Livros",
    path = D_PATH .. "calibre\\",
    dir_name = "livros"
  },
  ["wallpapers"] = {
    fmt_name = "Wallpapers",
    path = D_PATH .. "backups\\",
    dir_name = "wallpapers"
  },
  ["misc"] = {
    fmt_name = "Misc",
    path = D_PATH .. "backups\\",
    dir_name = "misc"
  }
}

DAILY = {
  ["keepass"] = {
    fmt_name = "KeePass",
    path = C_PATH .. "ohno\\",
    dir_name = "keepass"
  },
  ["notes"] = {
    fmt_name = "Notes",
    path = C_PATH .. "ohno\\",
    dir_name = "notes"
  }
}
-- =============
-- CODE
-- =============
json = require "json"

prog_handle = nil
prog_str_handle = nil

-- This function returns true if the
-- cloud_path reached the max_bytes size
-- limit.
function cloud_is_on_size_limit(max_bytes, cloud_path)
  prog_handle = io.popen("rclone size --json " .. cloud_path)
  prog_str_handle = prog_handle:read()
  local json_value = json.decode(prog_str_handle)
  prog_handle:close()

  if json_value["bytes"] >= max_bytes then
    return true
  else
    return false
  end
end

-- This function returns the first file
-- in cloud_path (alphabetical order).
-- Using a timestamp as a filename the oldest
-- is the first in this case.
function cloud_return_oldest_file(cloud_path)
  prog_handle = io.popen("rclone lsf " .. cloud_path)
  prog_str_handle = prog_handle:read()
  prog_handle:close()

  return prog_str_handle
end

-- This function deletes target in cloud_path.
-- Note that this is only for files not directories.
function cloud_delete_file(cloud_path, target)
  prog_handle = io.popen("rclone delete " .. cloud_path .. target)
  prog_str_handle = prog_handle:read()
  prog_handle:close()
end

-- This function uploads a file to cloud_path
-- using start /wait so the rclone progress can
-- be showed in a new cmd window.
function cloud_upload_file(file, cloud_path)
  local function_name = "start /wait rclone copy " .. file .. " " .. cloud_path .. " -P"
  prog_handle = io.popen(function_name)
  prog_handle:close()
end

-- This functions copies source to dest
-- using robocopy cmd from windows.
--          /e = copy empty folder
-- /copy:DATSO = copy everything, excluding audit info
--
-- NOTE(Geraldo): For christ's sake robocopy... I had to go to every single
--                folder listed on WEEKLY and DAILY and give permissions for this to work
function local_copy_dir(source, dest)
  local function_name = "robocopy " .. source .. " " .. dest .. " *.* /e /copy:DATSO"
  prog_handle = io.popen(function_name)

  prog_handle:close()
end

-- This function deletes a dir using
-- rmdir cmd from windows.
-- /q = silent mode
-- /s = remove all dirs and subdirs
function local_del_dir(dir)
  local function_name = "rd /q /s " .. dir
  prog_handle = io.popen(function_name)

  prog_handle:close()
end

-- This function deletes a file using
-- del cmd from windows.
function local_del_file(file)
  local function_name = "del " .. file
  prog_handle = io.popen(function_name)

  prog_handle:close()
end

-- This function uses 7zip to compress
-- the source to dest and spits out a
-- timestamp to the filename.
-- It also returns the final name.
function local_7z_dir(source, dest)
  local file_name_out = dest .. os.date("-%Y%m%d-%H%M%S") .. ".7z"
  local function_name = "7z a " .. file_name_out .. " " .. source
  prog_handle = io.popen(function_name)

  prog_handle:close()

  return file_name_out
end

-- This functions uses the 7zip test utility
-- and returns its output.
function local_7z_test(source)
  local function_name = "7z t " .. source .. " *"
  prog_handle = io.popen(function_name)
  prog_str_handle = prog_handle:read("*a")

  prog_handle:close()

  return prog_str_handle
end

-- This procedure copies everything
-- from a data structure like the
-- WEEKLY global var to a dest.
function proc_copy_data_to_bck_dir(data, dest)
  for index, _ in pairs(data) do
    local source = data[index].path .. data[index].dir_name
    local dest = dest .. "\\" .. data[index].dir_name
    local_copy_dir(source, dest)
    print_with_id("COPY", data[index].fmt_name .. " copied to " .. dest)
  end

  print_with_id("COPY", "Ok.")
end

-- This procedure compress the source to the dest
-- and tests it. If the test fails it returns
-- false, otherwise, true and the final name for the file.
function proc_7z_bck_dir(source, dest)
  print_with_id("7z", "Compressing " .. source .. " folder. This might take a while...")
  local result_file = local_7z_dir(source, dest)
  print_with_id("7z", "Testing...")
  local result_test = local_7z_test(result_file)

  for line in string.gmatch(result_test,'[^\r\n]+') do
    if line == "Everything is Ok" then
      print_with_id("7z", "Ok.")
      return {true, result_file}
    end
  end

  print_with_id("7z", "An error ocurred while compressing! Please run 7z t " .. result_file .. " to check the errors.")
  return false
end

-- This procedure checks the size limit
-- and asks if you want to delete the oldest
-- file. It return true if cloud_path has the
-- necessary size available and false otherwise.
function proc_check_and_delete(size_limit, cloud_path)
  if cloud_is_on_size_limit(size_limit, cloud_path) then
    print_with_id("WARNING", "Target cloud doesn't have the necessary size available.")
  else
    print_with_id("INFO", "Target cloud has the necessary size. Continuing...")
    return true
  end

  local oldest = cloud_return_oldest_file(cloud_path)
  print_with_id("QUESTION", "Do you want to delete the oldest file (" .. oldest .. ") to continue? [y/n]")
  local user_input = io.read("*l")
  while true do
    if user_input == "y" then
      print_with_id("INFO", "Deleting " .. oldest)
      cloud_delete_file(cloud_path, oldest)
      print_with_id("INFO", oldest .. " deleted with success.")
      return proc_check_and_delete(size_limit, cloud_path)
    elseif user_input == "n" then
      return false
    else
      print_with_id("QUESTION", "Please provide a valid answer.")
      user_input = io.read("*l")
    end
  end
end

-- This procedure is just a wrap for
-- cloud_upload_file with user msgs.
function proc_upload_file(file, cloud_path)
  print_with_id("CLOUD", "Uploading " .. file .. " this might take a while.")
  cloud_upload_file(file, cloud_path)
  print_with_id("CLOUD", file .. " uploaded with success.")
  print_with_id("CLOUD", "Ok.")
end

-- This procedure remove the temp folder
-- and the compressed file
function proc_cleanup(dir, file)
  print_with_id("CLEANUP", "Removing compressed file " .. file)
  local_del_file(file)
  print_with_id("CLEANUP", "Removing temp folder " .. dir)
  local_del_dir(dir)

  print_with_id("CLEANUP", "Ok.")
end

function print_with_id(id, msg)
  print("["..id.."]" .. " " .. msg)
end

function cmd_run_all(temp_path, cloud_path, size_limit, folders_struct)
  local result = proc_check_and_delete(size_limit, cloud_path)
  if not result then
    print_with_id("INFO", "Backup cancelled.")
    return
  end

  print("\n")
  print_with_id("INFO", "Copy started...")
  proc_copy_data_to_bck_dir(folders_struct, temp_path)

  print("\n")
  print_with_id("INFO", "Compression started...")
  result = proc_7z_bck_dir(temp_path, temp_path)
  if not result then
    return
  end

  print("\n")
  print_with_id("INFO", "Upload started...")
  proc_upload_file(result[2], cloud_path)

  print("\n")
  print_with_id("INFO", "Cleanup started...")
  proc_cleanup(temp_path, result[2])

  print("\n")
  print_with_id("DONE", "Everything went ok.")
end

function cmd_copy_only(temp_path, folders_struct)
  print_with_id("INFO", "Copy started...")
  proc_copy_data_to_bck_dir(folders_struct, temp_path)

  print("\n")
  print_with_id("DONE", "Everything went ok.")
end

function cmd_zip_only(temp_path, folders_struct)
  print_with_id("INFO", "Copy started...")
  proc_copy_data_to_bck_dir(folders_struct, temp_path)

  print("\n")
  print_with_id("INFO", "Compression started...")
  proc_7z_bck_dir(temp_path, temp_path)

  print("\n")
  print_with_id("DONE", "Everything went ok.")
end


if arg[1] == "-w" then
  if arg[2] == "--copy-only" then
    cmd_copy_only(TEMP_FOLDER_PATH_WEEKLY, WEEKLY)
  elseif arg[2] == "--zip-only" then
    cmd_zip_only(TEMP_FOLDER_PATH_WEEKLY, WEEKLY)
  else
    cmd_run_all(TEMP_FOLDER_PATH_WEEKLY,
                CLOUD_PATH_WEEKLY,
                SIZE_LIMIT_WEEKLY,
                WEEKLY
    )
  end

elseif arg[1] == "-d" then
  if arg[2] == "--copy-only" then
    cmd_copy_only(TEMP_FOLDER_PATH_DAILY, DAILY)
  elseif arg[2] == "--zip-only" then
    cmd_zip_only(TEMP_FOLDER_PATH_DAILY, DAILY)
  else
    cmd_run_all(TEMP_FOLDER_PATH_DAILY,
                CLOUD_PATH_DAILY,
                SIZE_LIMIT_DAILY,
                DAILY
    )
  end

else
  print_with_id("INFO", "Please select -d for daily or -w for weekly")
end
