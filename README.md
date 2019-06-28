# Redmine

Sassafras fork of Redmine: a flexible project management web application written using Ruby on Rails framework.

More details can be found in the `doc` directory or on the official website <http://www.redmine.org>.

## Development

### Local setup

Official, detailed instructions can be found in the `INSTALL` file. Some of the steps are out of date for 2019 since Sassafras is using an old fork.

It's recommended that you use a separate rbenv installation for this since it's so old (Ruby 2.2 is the max supported).

1. Install mysql:

    ```bash
    # For OSX (homebrew)
    brew install mysql@5.6
    brew link --force mysql@5.6
    sudo chown -R _mysql:mysql /usr/local/var/mysql
    sudo mysql.server restart
    ```

1. Create db: `mysql -u root -e "create database redmine; create database redmine_development;"`

1. Copy config files:

    ```bash
    cp config/database.yml{.example,}
    cp config/configuration.yml{.example,}
    cp config/additional_environment.rb{.example,}
    ```

1. Edit `config/database.yml` if needed; should be fine by default

1. Install old bundler: `gem install bundler -v "~> 1"`

1. Install dependencies: `bundle install --without rmagick`

    - To fix `mysql2` on mac: `gem install mysql2 -v '~> 0.3.21' -- --with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include`
    - You can try `brew install imagemagick@6` if you want rmagick

1. Do some initialization:

    ```bash
    bundle exec rake generate_secret_token
    bundle exec rake db:migrate RAILS_ENV=production
    ```

1. Configure access:

    ```bash
    # Probably unnecessary
    # sudo chown -R redmine:redmine files log tmp public/plugin_assets

    # Maybe unnecessary?
    sudo chmod -R 755 files log tmp public/plugin_assets
    ```

1. Verify it works:

    - `rails s -e production`
    - Open <http://localhost:3000/>
    - Sign in with credentials `admin`/`admin`

1. Load the defaults via <http://localhost:3000/admin>

### Plugin development

See [Redmine tutorial](http://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial) for more info.

1. Put any plugins in the `plugins/` directory, e.g. for GreenMachine:

    ```bash
    cd plugins
    git clone git@github.com:sassafrastech/greenmachine.git
    ```

1. Install plugin dependencies: `bundle install`

1. Restart the server for plugins to take effect

For GreenMachine specifically:

1. Copy config files: `cp lib/secrets.rb{.example,}`

1. Add QuickBooks keys to `lib/secrets.rb`
