import Foundation
import StaticSite
import HTML

struct WorkshopStarter: Rule {
    var body: some Rule {
        WriteNode(outputName: "index.html", node: [
            contents
        ])
    }

    @NodeBuilder var contents: Node {
        """
        # Workshop Starter Project

        This is a starter project to get you acquainted with SwiftUI. Depending on your prior experience and time, you can either get very far, but just starting to work on it for even an hour can be a great preparation for the [SwiftUI Workshop](https://www.swiftuifieldguide.com/workshops). Don’t feel the pressure to finish anything, the goal of this project is to explore and spend time with SwiftUI, not to build a fully functional app. If there's a specific part that interests you more, feel free to focus on that.

        ## Building a Reminders App

        In this project, we’ll build an app similar to Apple’s built-in Reminders app on your iPhone. Here's what we ended up with:
        
        <img src="/images/workshop-starter/step3.png" class="workshop-sim">

        ## Set up the structure

        Start a new Xcode project. Create a basic `Reminder` model struct that holds the title, whether the reminder is done and an optional date. Then, create some sample data (e.g. an array of sample reminders). Make sure your model conforms to the [`Identifiable`](https://developer.apple.com/documentation/Swift/Identifiable) protocol.

        ## Display a read-only version of the reminders

        Put the reminders in a `List`. Start by just display the title of each reminder. Then create a `ReminderView` view that displays the title, the list name (e.g. "Reminders") and the date (when provided). At first, it could look like this. (Don't focus on the styling just yet):
        
        <img src="/images/workshop-starter/step0.png" class="workshop-sim">

        ## Make the reminders editable
        
        To make a reminder editable, you need to pass a [binding](https://developer.apple.com/documentation/SwiftUI/Binding). Accept a `Binding<Reminder>` rather than a regular `Reminder` value in the `ReminderView`. Then change your list to work on a binding rather than a regular array of reminders.
        
        Once everything compiles, change the title to be a text field and add a `Toggle` to modify the `done` status.
        
        <img src="/images/workshop-starter/step1.png" class="workshop-sim">

        ## Style the `ReminderView`

        Make sure your title is bold and the date has a secondary foreground style. To style the `Toggle`, you can create a custom `ToggleStyle`.

        ##  Add an “Add Reminder” button

        Add a button to the bottom of the list. You can use the safe area insets to position it at the bottom. Use a custom button style to make it big and blue. The button doesn't have to do anything.
        
        <img src="/images/workshop-starter/step3.png" class="workshop-sim">

        ## More Ideas

        Can you implement more of the actual reminders app? For example, you could:

        - Have custom animations (e.g. for checking off a reminder)
        - Have multiple lists of reminders
        - Implement the logic of adding a reminder (use the focus APIs)
        - Store the reminders persistently (e.g. using Codable or using Swift Data)
        - Store the reminders online (e.g. using a quick val.town backend)
        - Make it possible to see the details of a reminder
        """.fromMarkdown
    }
}
