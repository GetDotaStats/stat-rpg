GetDotaStats Stat-Collection
=====

###About###
 - This repo allows mods to have persistant data over multiple plays. It would be most useful for RPGs.

# GetDotaStats - StatCollectionRPG specs 1.0 #

## Client --> Server ##

#### SAVE ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "SAVE", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.
|saveID    |Integer       |The unique save ID for this character, for this user.
|jsonData  |JSON          |The data of this character save.
|metaData  |JSON          |The metaData of this character save. It can be anything including JSON. It could be as simple as a name that users can set for their saves, or as complicated as something that will help render a snapshot of a character. This field must be lean, so that the LIST does not waste bandwidth!

#### DELETE ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "DELETE", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.
|saveID    |Integer       |The unique save ID for this character, for this user.

#### LOAD ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "LOAD", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.
|saveID    |Integer       |The unique save ID for this character, for this user.

#### LIST ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "LIST", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.

#### CREATE ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "CREATE", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.


## Server --> Client ##

#### success ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "success", as thats this packet

#### failure ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "failure", as thats this packet
|error     |String        |A string describing the error. Only useful for debugging purposes

#### load ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "load", as thats this packet
|jsonData  |JSON          |The data of this character save.

#### list (10 most recent for now) ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "list", as thats this packet
|jsonData  |Array of JSON |Contains an array of character metadata. For now this is simply the saveID and metaData

#### create ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "list", as thats this packet
|saveID    |Integer       |The next saveID to use
