## App Architecture

This app uses the **[MVP](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93presenter) (Model View Presenter)** Architechture pattern. (each View Controller is a View)

### Current Project Structure

* **Data** module contains Repositories and Models.
* **Presentation** module contains Views and Presenters. Each sub-module in Presentation represents a simple user story or feature like Login, Shares. This pattern is known as package by feature.
* **Base** module contains reusable functionalities for MVP Views and common UIViewController functionalities and
* **Extension** module contains extensions to first-class Swift classes and iOS Framework classes.

##### Presentation Logic
* `View` - delegates user interaction events to the `Presenter` and displays data passed by the `Presenter`
        * All `UIViewController`, `UIView`, `UITableViewCell` subclasses belong to the `View` layer
        * Usually the view is passive / dumb - it shouldn't contain any complex logic.
* `Presenter` - contains the presentation logic and tells the `View` what to present
        * Usually we have one `Presenter` per scene (view controller)
        * It doesn't reference the concrete type of the `View`, but rather it references the `View` protocol that is implemented usually by a `UIViewController` subclass
        * It should be a plain `Swift` class and not reference any `iOS` framework classes - this makes it easier to reuse it maybe in an `macOS` application

### Useful Resources

#### MVP & Other presentation patterns

* [Using MVP in iOS](http://iyadagha.com/using-mvp-ios-swift)
* [MVP Pattern in iOS](https://dzone.com/articles/mvp-pattern-in-ios)
* [iOS Architecture Patterns](https://medium.com/ios-os-x-development/ios-architecture-patterns-ecba4c38de52#.67lieoiim)
* [Architecture Wars - A New Hope](https://swifting.io/blog/2016/09/07/architecture-wars-a-new-hope/)
* [GUI Architectures, by Martin Fowler](https://martinfowler.com/eaaDev/uiArchs.html)
