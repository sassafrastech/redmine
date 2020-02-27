# Redmine

Sassafras fork of Redmine: a flexible project management web application written using Ruby on Rails framework.

More details can be found in the `doc` directory or on the official website [here](http://www.redmine.org).

Upstream changelog is [here](http://www.redmine.org/projects/redmine/wiki/changelog).

## Development

### Local setup

Official, detailed instructions can be found in the `INSTALL` file. However, most of what you need for Sassafras should be here.

Official upgrade steps between major versions are documented [here](https://www.redmine.org/projects/redmine/wiki/RedmineUpgrade).

Multiple environments (e.g. production/development) are NOT well supported. It's recommended to do this setup using **production only**.

1. Install mysql:

    ```bash
    # For OSX (homebrew)
    brew install mysql@5.6
    brew link --force mysql@5.6
    sudo chown -R _mysql:mysql /usr/local/var/mysql
    sudo mysql.server restart
    ```

1. Create db: `mysql -u root -e "create database redmine;"`

1. Copy config files:

    ```bash
    cp config/database.yml{.example,}
    cp config/configuration.yml{.example,}
    cp config/additional_environment.rb{.example,}
    ```

1. Edit `config/database.yml` if needed; should be fine by default

1. Install bundler: `gem install bundler`

1. Install dependencies: `bundle install --without rmagick`

    - To fix `mysql2` on mac: `gem install mysql2 -v '~> 0.3.21' -- --with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include`
    - You can try `brew install imagemagick@6` if you want rmagick

1. You **may** need to install a missing dependency if it asks: `gem install net-ldap`

1. Do some initialization:

    ```bash
    rails generate_secret_token
    RAILS_ENV=production rails db:migrate
    RAILS_ENV=production rails redmine:plugins:migrate
    ```

1. Configure access:

    ```bash
    # Probably unnecessary
    # sudo chown -R redmine:redmine files log tmp public/plugin_assets

    # Maybe unnecessary
    sudo chmod -R 755 files log tmp public/plugin_assets
    ```

1. Verify it works:

    - `rails s -e production`
    - Open <http://localhost:3000/>
    - Sign in with credentials `admin`/`admin`

1. Load the defaults via <http://localhost:3000/admin>

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

### Deploying

1. Push any changes
1. `git pull` changes manually for any plugins/themes
1. `bundle exec cap production deploy`
    1. Choose a branch (enter to select default)
