import {generate_loading_screen} from "./loading_screen.js";

export function testje(){
  console.log("ik werk!!");
}
/**
 * wrapper frunction to unwrap (single value) vectors from json
 * @param json
 * @returns json obj with unwrapped vectors
 */
export function dodona_lite(json){
  console.log("generated dodona lite -------------------")
  console.log(json);
  // for(const key in json) {
  //   json[key] = [json[key]];
  // }
  return generate_body(json);
}

// export function loading_screen(_){
//   console.log("generated loading_screen -------------------")
//   return generate_loading_screen();
// }


//description, feedback_content, feedback_names, code
function generate_body({type, submission=null, exercise}) {

    console.log(submission);

    const template = document.createElement("template");
    //template.acceptCharset = "UTF-8";


    const feedback_tables = function(submission) {
      console.log("feedback_tabs")
      console.log(Object.values(submission.feedback));
      return Object.values(submission.feedback).reduce((acc, curr) => {
        return acc + /*html*/`<div class='feedback-table'>${curr}</div>`;
      }, "");
    }
    const feedback_tabs = function(submission){
      console.log("feedback_tabs")
      console.log(Object.keys(submission.feedback));
      return Object.keys(submission.feedback).reduce((acc, curr) => {
        return acc + /*html*/`<div class='tab_header'>${curr}</div>`;
      }, "");
    }

    console.log(feedback_tabs);



    //const component = generate_component().innerHtml;

    template.innerHTML =/*html*/
    `<div id='exercise_tabs' class='tab-viewer'>
      <div class='tabs'>
        <div><img src="logo_dodona_inverse.png" alt="Dodona Logo" class='logo'></div>
        <div class='tab_header'>${type === "ContentPage" ? "Reading Activity" : "Exercise"}</div>
        ${type === "Exercise" ? /*html*/`<div class='tab_header'>Last Submission</div>` : ""}
      </div>
      <div class='panes'>
        <div>
          <div id="description-title">
            <div>${exercise.name}</div>
            <div>
              ${exercise.completed
                ? /*html*/`<span class='material-icons' style='color:green;'>check</span><span style='color:green;'>completed</span>`
                : /*html*/``
              }
            </div>
          </div>
          <iframe id="description"></iframe>
        </div>
        ${type === "Exercise" ?
          /*html*/
          `<div>
            <div id="description-title">
              <div>${exercise.name}</div>
              <div>
                ${exercise.completed
                  ? /*html*/`<span class='material-icons' style='color:green;'>check</span><span style='color:green;'>completed</span>`
                  : /*html*/``
                }
              </div>
            </div>
            ${submission !== null 
              ? `<div class='last-submission'>
                <!--<span class='description'>
                  Solution for <a href='${exercise.url}'>${exercise.name}</a> by <a href='${submission.user_url}'>you</a>
                </span>-->
                <div class='submission-status'>
                  ${status_icon_map[submission.status]}
                  <span>${capitalizeFirstLetter(submission.status)}</span>
                  <span>${timeSince(submission.created_at)}<span>
                </div>

                <div id='feedback_tabs' class='tab-viewer'>
                  <div class='tabs'>
                    ${feedback_tabs(submission)}
                    <div class='tab_header'>Code</div>
                  </div>
                  <div class='panes'>
                    ${feedback_tables(submission)}
                    <div>
                      <pre class='r'><code>${submission.code}</code></pre>
                    </div>
                  </div>
                </div>
              </div>`
              : `<span class='last-submission'>
                <span class='description'>
                  You have not yet submitted anything
                </span>
              </span>`
            }

            

          </div>` : ""
        }
      </div>
    </div>`

    template.content.getElementById("description").setAttribute("srcDoc", exercise.description);
    return template;
}

function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

const status_icon_map = {
  "compilation error": "<span class='material-icons' style='color:red; font-size:35px;'>bolt</span>",
  "runtime error": "<span class='material-icons' style='color:red; font-size:35px;'>flash_on</span>",
  "memory limit exceeded": "<span class='material-icons' style='color:red; font-size:35px;'>memory</span>",
  "time limit exceeded": "<span class='material-icons' style='color:red; font-size:35px;'>alarm</span>",
  "wrong": "<span class='material-icons' style='color:red; font-size:35px;'>close</span>",
  "correct": "<span class='material-icons' style='color:green; font-size:35px;'>check</span>",
  "queued": "",
  "running": "",
  "internal error": "<span class='material-icons' style='color:yellow; font-size:35px;'>warning</span>",
  "unknown": ""
}

function timeSince(date) {
  let seconds = Math.floor((new Date() - new Date(date)) / 1000);
  let interval = seconds / 31536000;

  if (interval > 1) {
    let years = Math.floor(interval)
    return `About ${years} ${years == 1 ? "year" : "years"} ago`;
  }
  interval = seconds / 2592000;
  if (interval > 1) {
    let months = Math.floor(interval)
    return `About ${months} ${months == 1 ? "month" : "months"} ago`;
  }
  interval = seconds / 86400;
  if (interval > 1) {
    let days = Math.floor(interval)
    return `About ${days} ${days == 1 ? "day" : "days"} ago`;
  }
  interval = seconds / 3600;
  if (interval > 1) {
    let hours = Math.floor(interval)
    return `About ${hours} ${hours == 1 ? "hour" : "hours"} ago`;
  }
  interval = seconds / 60;
  if (interval > 1) {
    let minutes = Math.floor(interval)
    return `About ${minutes} ${minutes == 1 ? "minute" : "minutes"} ago`;
  }
  interval = seconds / 10;
  if (interval > 1) {
    let seconds = Math.floor(interval) * 10
    return `About ${seconds} seconds ago`;
  }
  return " Just now";
}


// get_status_icon <- function(status, classes){
//   list(
//     "compilation error" = "<span class='material-icons' style='color:red; font-size:13px;'>bolt</span>",
//     "runtime error" = "<span class='material-icons' style='color:red; font-size:13px;'>flash_on</span>",
//     "memory limit exceeded" = "<span class='material-icons' style='color:red; font-size:13px;'>memory</span>",
//     "time limit exceeded" = "<span class='material-icons' style='color:red; font-size:13px;'>alarm</span>",
//     "wrong" = "<span class='material-icons' style='color:red; font-size:13px;'>close</span>",
//     "correct" = "<span class='material-icons' style='color:green; font-size:13px;'>check</span>",
//     "queued" = "",
//     "running" = "",
//     "internal error" = "<span class='material-icons' style='color:yellow; font-size:13px;'>warning</span>",
//     "unknown" = ""
//   )[[status]]
//
// }
