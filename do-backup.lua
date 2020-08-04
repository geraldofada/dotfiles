-- Just a simple script to backup my personal files
-- Windows only!
--
-- =============
-- CONFIG
--
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
function check_tools()
  assert(os.execute("rclone --version"))
  assert(os.execute("7z"))

  os.execute("cls")
  return true
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

main()
