-- Just a simple script to backup my personal files
-- Windows only!


-- =============
-- CONFIG
-- =============
SIZE_LIMIT = 10737418240 -- 10GB
TEMP_FOLDER_PATH = "recurring"
CLOUD_PATH = "gdrive_crypt_recrr:"
RECRR = {
  ["notes"] = {
    fmt_name = "Notes",
    path = "z:\\",
    dir_name = "notes"
  },
  ["uff"] = {
    fmt_name = "Uff",
    path = "z:\\",
    dir_name = "uff"
  },
  ["photos"] = {
    fmt_name = "Fotos",
    path = "d:\\backups\\",
    dir_name = "fotos"
  },
  ["docs"] = {
    fmt_name = "Documentos",
    path = "d:\\backups\\",
    dir_name = "documentos"
  },
  ["games"] = {
    fmt_name = "Jogos",
    path = "d:\\backups\\",
    dir_name = "jogos"
  },
  ["books"] = {
    fmt_name = "Livros",
    path = "d:\\calibre\\",
    dir_name = "livros"
  },
  ["wallpapers"] = {
    fmt_name = "Wallpapers",
    path = "d:\\backups\\",
    dir_name = "wallpapers"
  },
}
to_backup = {
  ["slipbox"] = {
    path_local = "z:/notes/slipbox",
    path_dropbox = "dropbox:Slipbox",
    path_googledrive = "googledrive:/Backups/Slipbox",
  },
  ["finance"] = {
    path_local = "z:/notes/finance",
    path_dropbox = "dropbox:Finance",
    path_googledrive = "googledrive:/Backups/Finance"
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
function cloud_upload_file(file, cloud_path)
  local function_name = "rclone copy " .. file .. " " .. cloud_path
  prog_handle = io.popen(function_name)
  prog_handle:close()
end

-- This functions copies source to dest
-- using xcopy cmd from windows.
-- /r = copy empty folder
-- /i = make sure dest is a folder
function local_copy_dir(source, dest)
  local function_name = "xcopy /e /i " .. source .. " " .. dest
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

function check_tools()
  assert(os.execute("rclone --version"))
  assert(os.execute("7z"))

  os.execute("cls")
  return true
end

-- TODO(geraldo) learn how to add more than one dir in 7z
-- the alg will be something like this:
--     is_on_size_limit
--     if false: just zip everything, add timestamp and up
--     if true: get oldest, remove it then check again is_on_size_limit

-- This is a procedure that copies everything
-- in RECRR to TEMP_FOLDER_PATH.
function proc_copy_to_bck_dir()
  for index, _ in pairs(RECRR) do
    local source = RECRR[index].path .. RECRR[index].dir_name
    local dest = TEMP_FOLDER_PATH .. "\\" .. RECRR[index].dir_name
    local_copy_dir(source, dest)
    print_with_id("COPY", RECRR[index].fmt_name .. " copied to " .. dest)
  end

  print_with_id("COPY", "Ok.")
end

-- This procedure compress the TEMP_FOLDER_PATH
-- and tests it. If the test fails it returns
-- false and true otherwise.
function proc_7z_bck_dir()
  print_with_id("7z", "Starting compression, this might take a while...")
  local result_file = local_7z_dir(TEMP_FOLDER_PATH, TEMP_FOLDER_PATH)
  print_with_id("7z", "Testing...")
  local result_test = local_7z_test(result_file)

  for line in string.gmatch(result_test,'[^\r\n]+') do
    if line == "Everything is Ok" then
      print_with_id("7z", "Ok.")
      return true
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
    print_with_id("WARNING", "Destined cloud doesn't have the necessary size available.")
  else
    print_with_id("INFO", "Destined cloud has the necessary size. Continuing.")
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


function backup_dir(path_in, path_out)
  local file_name_out = path_out .. os.date("-%Y%m%d-%H%M%S") .. ".7z"
  local function_name = "7z a " .. file_name_out .. " " .. path_in
  assert(os.execute(function_name))
  os.execute("cls")

  return {true, file_name_out}
end

function upload_dir(local_path, cloud_path)
  local function_name = "rclone copy " .. local_path .. " " .. cloud_path
  assert(os.execute(function_name))
  os.execute("cls")

  return true
end

function cleanup(dir_to_del)
  local function_name = "del " .. dir_to_del
  assert(os.execute(function_name))
  os.execute("cls")

  return true
end

function print_with_id(id, msg)
  print("["..id.."]" .. " " .. msg)
end

function main()
  if check_tools() then
    print("All tools. OK")
  else
    print("Please make sure that 7z and rclone are installed!")
    return
  end

  -- loop through all config
  local result
  for index, _ in pairs(to_backup) do

    result = backup_dir(to_backup[index].path_local, index)
    if result[1] then
      print_with_id(index, "Local backup. OK")
    else
      print_with_id(index, "Something went wrong making the backup locally.")
      return
    end

    if upload_dir(result[2], to_backup[index].path_googledrive) then
      print_with_id(index, "Google Drive backup. OK.")
    else
      print_with_id(index, "Something went wrong uploading to Google Drive.")
      return
    end

    if upload_dir(result[2], to_backup[index].path_dropbox) then
      print_with_id(index, "Dropbox backup. OK.")
    else
      print_with_id(index, "Something went wrong uploading to Dropbox.")
      return
    end

    if cleanup(result[2]) then
      print_with_id(index, "Cleanup. OK")
      os.execute("cls")
    else
      print_with_id(index, "Something went wrong cleaning up.")
      return
    end

  end
end

-- main()

print(return_oldest_file("googledrive:Backups/Finance"))
