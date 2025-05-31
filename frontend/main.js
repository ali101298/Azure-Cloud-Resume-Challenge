// an event listener which listens to an event when a content is loaded and then calls the visit counter function.
window.addEventListener('DOMContentLoaded', (event) => getVisitCount());

// Just setting the initial functionApi value to an empty string
const functionApi = '';

// a function to get the visitor count from the function API
const getVisitCount = () => {

    // just setting an initial value of visit counts
    let count = 30;

    /* Here, we are getting the actual visit count by fetching the Azure Function API's response
    in an event a user visits the site and then returning the updated count.*/
    fetch(functionApi).then(response => {
        return response.json();
    }).then(response => {
        console.log("Azure function API is successfully called!");
        count = response.count;
        document.getElementById("counter").innerHTML = count;
    }).catch(function(error) {
        console.error;
    });

    return count;
}