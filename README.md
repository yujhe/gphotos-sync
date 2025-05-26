# GPHOTOS-SYNC

A Docker container which runs the [yujhe/gphoto-cdp](https://github.com/yujhe/gphotos-cdps) tool automatically to synchronize Google Photos to local filesystem.

Worked based on [spraot/gphotos-sync](https://github.com/spraot/gphotos-sync) (Thanks to @spraot).

## Quickstart

### Requirement

Docker installation is required.

If you are running on Synology NAS, you need to execute docker by non-root user, follow the steps to setup permission:

```sh
# create the group "docker" from the ui or cli
sudo synogroup --add docker
# make it the group of the docker.sock
sudo chown root:docker /var/run/docker.sock
# assign the user to the docker group in the ui or cli
sudo synogroup --member docker {username}
```

### Step 1: Create Authenticated Profile Directory

Execute [doauth.sh](doauth.sh) and follow the instructions to complete the authentication on browser. It will help you to create authenticated profile directory `profile/`.

```sh
Open chrome by using the open-chrome.sh script then close that browser window (inside the container) before continuing
Press any key after you have authenticated in your browser at http://localhost:6080
```

If you are running on Synology NAS, you can login on your computer and copy the authenticated profile directory to `${folder}/profile/` on remote server.

### Step 2: Sync Photos/Album from Google Photos

Execute [dosync.sh](dosync.sh) to sync photos/album from Google Photos to local. You can modify `sync_args` in [dosync.sh](dosync.sh) to customize the syncing job.

```sh
sync_args=(
  # DO NOT CHANGE: paths in docker container
  "-profile /profile"              # user-provided profile dir
  "-download-dir /downloads"       # where to write the downloads
  "-db-file /db/gphotos.db"        # database file

  "-headless"        # Start chrome browser in headless mode
  "-log-level info"   # log level: debug, info, warn, error, fatal, panic

  "-workers 3"       # number of concurrent downloads allowed
  # "-batch-size 10"   # number of photos to be downloaded in one batch

  "-run /app/mv_photo_dir.sh"   # the program to run on each downloaded item, right after it is dowloaded

  # uncomment this, if you want to sync album
  # "-album id"         # ID of album to download, has no effect if lastdone file is found or if -start contains full UR
  # "-album-type album" # type of album to download (as seen in URL)

  # uncomment this, if you want to sync photos after the date (inclusive)
  # "-from yyyy-mm-dd"   # earliest date to sync (YYYY-MM-DD)

  # uncomment this, if you want to skip downloading photos
  # "-skip-download" # skip downloading photos, only update the database
)
```

### Known Issues

#### Language

It may be necessary to set your account language to "English (United States)" for this to work (see [#2](https://github.com/spraot/gphotos-sync/issues/2)). This is the likely cause if you see date parsing errors or similar.

#### Highlight Videos

Google Photos has a feature that automatically generates highlight videos. If you save these to your account, they can cause issues with syncing. Generally they cannot be downloaded or viewed from the browser and they occasionally cause the Google Photos UI (and therefore this sync service) to freeze. I suggest deleting these from your account and restarting the sync service. If you still see issues check that your .lastdone file does not contain the URL to a highlight video.
