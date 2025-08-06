#!/bin/bash

# Increments the latest tag and makes a release
# This triggers the BigWigs packager
increment_tag_and_release()
{
    tag="v0"

    # If -v was provided, use it as the tag. Otherwise just increment from most recent tag.
    while getopts 'v:' OPTION; do
        case "$OPTION" in
        v)
            tag="$OPTARG"
            ;;
        ?)
            echo "script usage: git release [-v tagname]"
            exit 1
            ;;
        esac
    done

    # Find the latest tag
    lastTag=$(git tag | sort -V | tail -1);

    # If a latest tag exists (i.e. this is not the first ever release), increment it
    if [[ -n "$lastTag" ]]
    then
        tag="v"$(($"${lastTag:1}"+1));
    fi

    git tag $tag;
    git push origin master && git push origin $tag;
}

# Checks if there are any updates to WeakAuras
# If so, generate WeakAuras.lua to reflect them, and automatically up their version numbers.
update_weakauras()
{
    # Check if the WeakAuras folder exists
    if ! [ -d "WeakAuras/Mandatory" ]
    then
        echo "WeakAuras folder does not exists!"
        mkdir -p WeakAuras/Mandatory
        return 1
    fi

    # Check if the Generated folder exists
    if ! [ -d "WeakAuras/.generated" ]
    then
        echo "Generated folder does not exists!"
        # make one
        mkdir -p WeakAuras/.generated
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
    # Check if versions.json exists, if not create it
    if ! [ -f "WeakAuras/.generated/versions.json" ]
    then
        echo "versions.json does not exist, creating it"
        # Create an empty versions.json file
        echo "{}" > WeakAuras/.generated/versions.json
        updated_json=$(jq '.' WeakAuras/.generated/versions.json)
    fi

    updated_json=$(jq '.' WeakAuras/.generated/versions.json)

    # Loop over aura files and check if any of them were updated
    files="WeakAuras/Mandatory/*.txt"
    for f in $files
    do
      echo "Processing $f"
        filename=$(basename "$f")
        auraname="${filename%.*}"
        auradata=$(<"$f")

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
#    git add .
#    git commit --allow-empty -m "WeakAura update"
}

## Check if we are on the master branch before releasing
#if ! [[ $(git branch --show-current) == "master" ]]
#then
#    echo "you are not on master."
#    return 1
#fi
#
## Fetch remote release tags, in case we do not have them locally yet
#git fetch --tags origin master;
#
## Check if we are up to date with master
#if ! [[ $(git rev-list @..master --count) -eq 0 ]]
#then
#    echo "behind master, please pull before release."
#    return 1
#fi

update_weakauras

# Check if there are actually any staged commits to release
# If not, make an empty commit
#if ! [[ $(git rev-list FETCH_HEAD..master --count) -gt 0 ]]
#then
#    git commit --allow-empty "Release"
#fi

#increment_tag_and_release