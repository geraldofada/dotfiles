-- Just a simple script to backup my personal files
-- Windows only!
--
-- =============
-- CONFIG

-- Backup this:
SLIPBOX = "Z:\\slipbox"
-- into this:
DROPBOX = "dropbox:Slipbox"
GOOGLEDRIVE = "googledrive:/Backups/Slipbox"

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

function main()
  local result

  if not check_tools() then
    print("Please make sure that 7z and rclone are installed!")
    return
  else
    print("All tools. OK")
  end

  result = backup_dir(SLIPBOX, "slipbox")
  if not result[1] then
    print("Something went wrong making the backup locally.")
    return
  else
    print("Local backup. OK")
  end

  if not upload_dir(result[2], GOOGLEDRIVE) then
    print("Something went wrong uploading to Google Drive.")

  else
    print("Google Drive backup. OK.")
  end

  if not upload_dir(result[2], DROPBOX) then
    print("Something went wrong uploading to Dropbox.")
    return
  else
    print("Dropbox backup. OK.")
  end

  if not cleanup(result[2]) then
    print("Something went wrong cleaning up.")
    return
  else
    print("Cleanup. OK")
    os.execute("cls")
  end

  print("Done!")
end

main()
