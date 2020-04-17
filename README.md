# TransitionsListener

This gem was inspired by [State Machine](https://github.com/pluginaweek/state_machine)
to listen all state transitions and make actions before and after the transition is saved.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'transitions_listener'
```

And then execute: ```bundle install```


## Usage 
```ruby
# == Schema Information
#
# Table name: articles
#
#  id              :bigint
#  state           :string
  
class Article < ActiveRecord::Base
  include TransitionsListener
  listen_transitions :state do
    after_transition active: :inactive do |article, transition|
      # article.send_inactive_email
    end
    before_transition any => :deleted do |article, transition|
      # article.errors.add(:base, "not possible") if article.active_carts.any?
    end
  end
end
```

## API
- ````listen_transitions(attr_name){block}```` permit to define state transitions listener for a specific model attribute
- ````before_transition(states){block}```` permit to listen transitions before the new state is saved (Before update)
- ````after_transition(states){block}```` permit to listen transitions after the new state was saved (After update)

States can be defined as the following:
- ```before_transition(any => any)``` block will be called when attr value is changed from any value to any value
- ```before_transition(any => :active)``` block will be called when attr value is changed from any value to :active
- ```before_transition(:active => any)``` block will be called when attr value is changed from :active value to any value
- ```before_transition(%i[active inactive] => %i[deleted cancelled])``` block will be called when attr value is changed from :active or inactive to :deleted or :cancelled
- ```before_transition(active: :inactive, inactive: :deleted)``` block will be called when attr value is changed from :active to :inactive or :inactive to :deleted

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/transitions_listener. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TransitionsListener project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/transitions_listener/blob/master/CODE_OF_CONDUCT.md).
