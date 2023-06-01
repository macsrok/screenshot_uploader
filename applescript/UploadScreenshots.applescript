on adding folder items to this_folder after receiving these_items
	set user_profile_path to "PATH_TO_PROFILE"
	set minio_folder_action_path to "PATH_TO_FOLDER_CONTAINGING upload_to_minio.rb"
	set ruby_path to "PATH_TO_RUBY"
	set uploader_script_path to (minio_folder_action_path & "upload_to_minio.rb -f ")
	repeat with i from 1 to number of items in these_items
		set this_item to item i of these_items
		set the item_path to the quoted form of the POSIX path of this_item
		tell application "Terminal"
			do script ("source " & user_profile_path & " && cd " & minio_folder_action_path & " && " & ruby_path & " " & uploader_script_path & item_path)
		end tell
		delay 1
		tell application "Terminal" to Â
			set visible of Â
				(first window whose name contains "upload_to_minio") to false
	end repeat
end adding folder items to