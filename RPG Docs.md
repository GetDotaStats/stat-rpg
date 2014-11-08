# GetDotaStats - StatCollectionRPG specs 1.0 #

TODO: Examples

Rule of thumb, uppercase packets are client-->server and lowercase packets are server-->client


## Client --> Server ##
INSERT ANOTHER DESCRIPTION HERE

#### SAVE ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "SAVE", as thats this packet..
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.
|saveID    |Integer       |The unique save ID for this character, for this user.
|jsonData  |JSON          |The data of this character save.
|metaData  |String        |The metaData of this character save. It can be anything including JSON

#### DELETE ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "DELETE", as thats this packet..
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.
|saveID    |Integer       |The unique save ID for this character, for this user.

#### LOAD ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "LOAD", as thats this packet..
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.
|saveID    |Integer       |The unique save ID for this character, for this user.

#### LIST ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "LIST", as thats this packet..
|modID     |String        |The modID allocated by GetDotaStats
|steamID   |Long          |The SteamID of the owner of this save.


## Server --> Client ##
INSERT YET ANOTHER DESCRIPTION HERE

#### success ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "success", as thats this packet..

#### failure ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "failure", as thats this packet..

#### load ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "load", as thats this packet..
|jsonData  |JSON          |The data of this character save.

#### list (10 most recent only) ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "list", as thats this packet..
|jsonData  |Array of JSON |Contains an array of character metadata. For now this is simply the saveID and metaData
