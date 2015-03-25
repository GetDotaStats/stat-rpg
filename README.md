GetDotaStats Stat-RPG
=====

###About###
 - This library allows mods to have persistent data over multiple plays. It would be most useful for RPGs.


## Client --> Server ##

#### CREATE ####

Call this function just before a user creates a new character. Keep in mind that each user is allowed 6 save slots per mod, and that this function only generates an ID (it does not reserve it).

|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "CREATE", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.

Client --> {"type":"CREATE","modID":"XXXXXXXXX","steamID":"1234"}
Server --> {"type":"create","result":"success","saveID":"1"}

#### SAVE ####

Call this function when you want to update the data saved for a specific saveID. The saveID is obtained from the LIST or CREATE functions. A save can only collide with other saves from the same user. 

|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "SAVE"
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.
|saveID    |Integer       |The unique save ID for this character, for this user.
|jsonData  |JSON          |The data of this character save, in the form of a JSON array
|metaData  |JSON          |The metaData of this character save. It can be anything including JSON. It could be as simple as a name that users can set for their saves, or as complicated as something that will help render a snapshot of a character. This field must be lean, so that the LIST does not waste bandwidth!

Client --> {"type":"SAVE","modID":"XXXXXXXXX","steamID":"1234","saveID":"1","jsonData":"big_array_of_data","metaData":"example_character_save_name"}
Server --> {"type" : "save", "result" : "success"}

#### DELETE ####

Call this function when you want to delete a saveID. The saveID is obtained from the LIST or CREATE functions. A save can only collide with other saves from the same user.

|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "DELETE"
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.
|saveID    |Integer       |The unique save ID for this character, for this user.

Client --> {"type":"DELETE","modID":"XXXXXXXXX","steamID":"1234","saveID":"1"}
Server --> {"type" : "delete", "result" : "success"}

#### LOAD ####

Call this function when you want to load a specific saveID. The saveID is obtained from the LIST or CREATE functions. A save can only collide with other saves from the same user.

|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "LOAD"
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.
|saveID    |Integer       |The unique save ID for this character, for this user.

Client --> {"type":"LOAD","modID":"XXXXXXXXX","steamID":"1234","saveID":"1"}
Server --> {"type":"load","result":"success","jsonData":"big_array_of_data"}

#### LIST ####

Call this function at the start of the game to get a list of all of the user's saves for this mod.

|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "LIST"
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.

Client --> {"type":"LIST","modID":"XXXXXXXXX","steamID":"1234"}
Server --> {"type":"list","result":"success","jsonArray":[{"saveID":1,"metaData":"example_character_save_name","dateRecorded":"2015-03-25T02:08:53.000Z"},{"saveID":2,"metaData":"example_character_save_name","dateRecorded":"2015-03-25T02:19:56.000Z"},{"saveID":3,"metaData":"example_character_save_name","dateRecorded":"2015-03-25T02:20:01.000Z"},{"saveID":4,"metaData":"example_character_save_name","dateRecorded":"2015-03-25T02:20:06.000Z"}]}

## Server --> Client ##

Always listen for the error and result fields. If error is populated, then something went wrong and you may want to indicate the raw error to the user in the client, otherwise you may want to communicate the result to the user (optional).

#### on success ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|result    |String        | String describing success, only useful for debugging

#### on failure ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|error     |String        |A string describing the error. Only useful for debugging purposes

#### create ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "list"
|saveID    |Integer       |The next saveID to use

#### save ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "save"

#### delete ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "delete"

#### load ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "load"
|jsonData  |JSON          |The data of this character save.

#### list (6 most recent for now) ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "list"
|jsonArray |Array of JSON |Contains an array of character meta-data and when it was saved

## Ports ##

* Live: 4446
* Test: 4444
