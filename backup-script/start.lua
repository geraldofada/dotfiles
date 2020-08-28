-- Just a simple script to backup my personal files
-- Windows only!
--
-- =============
-- CONFIG
--
SIZE_LIMIT = 10737418240 -- 10GB
RECRR = {
  ["notes"] = {
    fmt_name = "notes"
    path = "z:/notes/"
  },
  ["uff"] = {
    fmt_name = "uff"
    path = "z:/uff/"
  },
  ["photos"] = {
    fmt_name = "fotos"
    path = "d:/backups/fotos/"
  },
  ["docs"] = {
    fmt_name = "documentos"
    path = "d:/backups/documentos/"
  },
  ["games"] = {
    fmt_name = "jogos"
    path = "d:/backups/jogos/"
  },
  ["books"] = {
    fmt_name = "livros"
    path = "d:/calibre/livros/"
  },
  ["wallpapers"] = {
    fmt_name = "wallpapers"
    path = "d:/backups/wallpapers/"
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
--

json = require "json"

prog_handle = nil
prog_str_handle = nil

-- This function returns true if the
-- cloud_path reached the max_bytes size
-- limit.
function is_on_size_limit(max_bytes, cloud_path)
  prog_handle = io.popen("rclone size --json " .. cloud_path)
  prog_str_handle = prog_handle:read()
  local json_value = json.decode(prog_str_handle)

  if json_value["bytes"] >= max_bytes then
    return true
  else
    return false
  end

  prog_handle:close()
end

-- This function returns the first file
-- in cloud_path (alphabetical order).
-- Using a timestamp as a filename the oldest
-- is the first in this case.
function return_oldest_file(cloud_path)
  prog_handle = io.popen("rclone lsf " .. cloud_path)
  prog_str_handle = prog_handle:read()
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
-- TODO(geraldo) cleanup the config part, and figure out how
-- will be the new dir structure.
-- TODO(geraldo) to finalize, configure rclone to encrypt data
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
