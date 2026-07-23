# Redmine

Sassafras fork of Redmine: a flexible project management web application written using Ruby on Rails framework.

More details can be found in the `doc` directory or on the official website [here](http://www.redmine.org).

Upstream changelog is [here](http://www.redmine.org/projects/redmine/wiki/changelog).

## Development

### Local setup

Official, detailed instructions can be found in the `INSTALL` file. However, most of what you need for Sassafras should be here.

Official upgrade steps between major versions are documented [here](https://www.redmine.org/projects/redmine/wiki/RedmineUpgrade).

Multiple environments (e.g. production/development) are NOT well supported. It's recommended to do this setup using **production only**.

1. Install mysql and link it to make sure the ruby gem finds it:

    ```bash
    # For OSX (homebrew)
    brew install mysql mysql-client

    # Then do what it says, e.g.:
    echo 'export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"' >> ~/.zshrc
    brew services start mysql
    bundle install

    # OR:
    gem install mysql2 -v 0.5.7 -- --with-mysql-config=$(brew --prefix mysql-client)/bin/mysql_config
    ```

1. Copy config files:

    ```bash
    cp config/database.yml{.example,}
    cp config/configuration.yml{.example,}
    cp config/additional_environment.rb{.example,}
    ```

1. Edit `config/database.yml` if needed; should be fine by default

1. Install bundler: `gem install bundler`

1. Install dependencies: `bundle install` # Or optionally: `bundle install --without rmagick`

1. Make sure a secret is set: `bundle exec rake generate_secret_token` # Is this format old?

1. If there's old data you want to purge: `mysql -u root -e "drop database redmine_development;"`

1. Do some initialization:

    ```bash
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake redmine:plugins:migrate # This will fail for old plugins, you need to modify the source code in to change old "ActiveRecord::Migration" to "ActiveRecord::Migration[4.2]"
    bundle exec rake redmine:load_default_data # Follow prompts
    ```

    - Sassy plugins include:
      - https://github.com/sassafrastech/greenmachine
      - https://github.com/alphanodes/additionals
      - https://github.com/alphanodes/additional_tags
      - https://www.redmineup.com/pages/plugins/agile

1. If it fails, you may need to ensure file ownership, e.g.: `sudo chown -R redmine:redmine files log tmp public/plugin_assets`

1. Verify it works:

    - `bundle exec rails s -e production`
    - Open <http://localhost:3000/>
    - Sign in with credentials `admin`/`admin` (requires reset on first login)

1. Configure settings in your browser, e.g. the Sassafras theme at <http://localhost:3000/settings?tab=display>

### Local dev

1. Watch for changes with `bundle exec rerun --dir app,config,plugins,public rails s -- -e production`
    - Note: if you try to refresh the page before it's ready you'll break things and see `Cannot GET /route`; simply restart the server in this case (hotkey: `r`)

### Copying data

If you want to mirror the live database, download a dump and then:

1. `mysql -u root redmine < dump.sql`

### Plugin development

See [Redmine tutorial](http://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial) for more info.

1. Put any plugins in the `plugins/` directory, e.g. for GreenMachine:

    ```bash
    cd plugins
    git clone git@github.com:sassafrastech/greenmachine.git
    ```

1. Install new dependencies as usual (from project root, not plugins root): `bundle install`

1. Restart the server for plugins to take effect

For GreenMachine specifically, docs are [here](https://github.com/sassafrastech/greenmachine).

### Themes

1. Put any themes in the `public/themes/` directory, e.g. for Sassafras:

    ```bash
    cd public/themes
    git clone https://github.com/sassafrastech/redmine-circle-theme.git sassafras
    ```

1. Restart the server for themes to be available

For the Sassasfras theme specifically, docs are [here](https://github.com/sassafrastech/redmine-circle-theme).

## Production

### New server setup

1. `sudo adduser deploy`
   1. Add SSH keys to the deploy user also
1. Follow https://www.phusionpassenger.com/docs/advanced_guides/install_and_upgrade/ instructions to install Passenger
   1. Their docs are a bit outdated, make sure to replace `jammy` (Ubuntu 22) with e.g. `resolute` (Ubuntu 26) in `/etc/apt/sources.list.d/passenger.list` based on your Ubuntu version.
   1. Also `sudo apt install libnginx-mod-http-passenger`
1. Follow https://mariadb.com/docs/server/mariadb-quickstart-guides/installing-mariadb-server-guide instructions to install MariaDB
   1. Initialize the database using the redmine guide: https://www.redmine.org/projects/redmine/wiki/RedmineInstall
1. Follow https://github.com/rbenv/rbenv instructions to:
   1. Install rbenv (don't use apt, use git on the deploy user)
   1. Install the ruby version specified in `.ruby-version` (on deploy user)
1. Copy over the `shared` folder if there's an existing server to migrate
1. Follow the steps below to deploy the code initially
1. Import a database dump: `mysql -u root redmine < dump.sql`

### Deploying updates

See full upgrade guide: https://www.redmine.org/projects/redmine/wiki/RedmineUpgrade

1. Locally: Push changes to github
1. On server plugins/themes directories: `git pull` any changes manually
1. Locally: `bundle exec cap production deploy`
    1. Choose a branch (enter to select default)

### Uninstalling a plugin

1. Remove from database: `bundle exec rake redmine:plugins:migrate NAME=foo VERSION=0 RAILS_ENV=production`
1. Remove from disk: `rm -rf plugins/foo/`
