#!/bin/bash

update_weakauras()
{
    # Check if the WeakAuras folder exists
    if ! [ -d "WeakAuras/Mandatory" ]
    then
        echo "WeakAuras folder does not exists!"
        return 1
    fi

    # Check if the Generated folder exists
    if ! [ -d "WeakAuras/.generated" ]
    then
        echo "Generated folder does not exists!"
        return 1
    fi

    # Check if we have jq (json parser) installed. If not, suggest curl script to install it.
    if ! [[ $(jq --version) ]]
    then
        echo -e "\njq not found, try:"
        echo "curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe"
        echo "(in admin mode)"
        return 1
    fi

    lua_tables=""
    updated_json=$(jq '.' WeakAuras/.generated/versions.json)

    # Loop over aura files and check if any of them were updated
    files="WeakAuras/Mandatory/*.txt"
    for f in $files
    do
        filename=$(basename "$f")
        auraname="${filename%.*}"
        auradata=$(cat "$f")

        # Check if the file contains a weakaura (just check the weakaura prefix)
        if ! [[ $auradata == "!WA:2!"* ]]
        then
            continue
        fi

        # Look for the last released version number in the versions.json file
        version=$(jq --arg an "$auraname" --raw-output '.[$an].version' <<< "$updated_json")

        # If we couldn't find an existing version, this is version 1
        if [[ $version = null ]]
        then
            echo "New aura detected: "${filename%.*}
            version=1
        else
            # Check if any changes were made to the aura since the last release
            # If not we don't up the version number
            cmp -s "WeakAuras/Mandatory/$filename" "WeakAuras/.generated/$filename"
            if [ $? -eq 0 ] # Files are identical
            then
                # Create the lua table entry for WeakAuras.lua
                lua_tables=$lua_tables"{version="$(($version))",displayName=\""$auraname"\",data=\""$auradata"\",},"

                continue
            elif [ $? -eq 1 ] # Files are different
            then
                echo "New version detected: "${filename%.*} "["$version"->"$((version+1))"]"
                version=$((version+1)) # Increment version
            else
                echo "Something went wrong while comparing versions for "$filename
                return 1
            fi
        fi

        # Create the lua table entry for WeakAuras.lua
        lua_tables=$lua_tables"{version="$(($version))",displayName=\""$auraname"\",data=\""$auradata"\",},"

        # Copy the aura to the generated folder
        cp "WeakAuras/Mandatory/$filename" "WeakAuras/.generated/$filename"

        # Update version in versions.json
        updated_json=$(jq --arg an "$auraname" --arg av "$version" '.[$an].version = $av' <<< "$updated_json")
    done

    # Increase version numbers in versions.json
    printf "$updated_json" > WeakAuras/.generated/versions.json

    # Generate WeakAuras.lua
    lua_tables="local _, LUP = ...; LUP.WeakAuras = {"$lua_tables"}"
    printf "$lua_tables" > WeakAuras.lua

    # Commit changes (assume all remaining changes are WeakAura updates)
    git add .
    git commit --allow-empty -m "WeakAura update [skip]"
}

update_weakauras