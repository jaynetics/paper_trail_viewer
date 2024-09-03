[![Gem Version](https://badge.fury.io/rb/paper_trail_viewer.svg)](http://badge.fury.io/rb/paper_trail_viewer)
[![Build Status](https://github.com/jaynetics/paper_trail_viewer/actions/workflows/tests.yml/badge.svg)](https://github.com/jaynetics/paper_trail_viewer/actions)

# PaperTrailViewer

Browse changes to records when using Ruby on Rails and the [`paper_trail`](https://github.com/paper-trail-gem/paper_trail) gem.

[
  ![Screenshot thumbnail showing the webapp](
    https://user-images.githubusercontent.com/10758879/160241794-9b9e9552-722f-48e2-9b1d-9ad463b99020.png
  )
](https://user-images.githubusercontent.com/10758879/160241664-fa1a6c08-54f1-4d32-9010-16b501b70f60.png)

## Installation

Add `paper_trail_viewer` to your bundle and add the following line to your `config/routes.rb`:

```ruby
mount PaperTrailViewer::Engine => '/changes'
```

You can pick any path. Restart the server and go to the chosen path to view your versions.

To limit access, do something like this:

```ruby
authenticate :user, ->*{ |u| u.superadmin? } do
  mount PaperTrailViewer::Engine => '/changes'
end
```

### Configuration

Put configuration in `config/initializers/paper_trail_viewer.rb`.

E.g. for linking (or not) to the whodunnit user with a custom path helper:

```ruby
PaperTrailViewer.user_path_method = :admin_path # default is :user_path
PaperTrailViewer.user_path_method = nil # don't link to the user
```

Other options are:

- `PaperTrailViewer.allow_rollback` (default is `true`)
- `PaperTrailViewer.data_source` (default is `ActiveRecord`)

## Development

### Setup

* Clone the repository
* Go into the directory
* Run `bin/setup` to install Ruby and JS dependencies

### Running tests

`bundle exec rake`

## License

This program is provided under an MIT open source license, read the [LICENSE.txt](https://github.com/jaynetics/paper_trail_viewer/blob/master/LICENSE.txt) file for details.

## To Note:

This project started as a fork of [PaperTrailManager](https://github.com/fusion94/paper_trail_manager), which was originally developed by [Igal Koshevoy](https://github.com/igal), [Reid Beels](https://github.com/reidab), and [Micah Geisel](https://github.com/botandrose).
