/**
 * wrapper frunction to unwrap (single value) vectors from json
 * @param json
 * @returns json obj with unwrapped vectors
 */
function dodona_lite(json){
  console.log("json: ", json);
  for(key of Object.keys(json)) {
    json[key] = [json[key]];
  }
  return generate_body(json)
}



function generate_body({description, feedback_content, feedback_names, code}) {
    const template = document.createElement("template");

    const feedback_tables = feedback_content.reduce((acc, curr) => {
      return acc + /*html*/`<div class='feedback-table'>${curr}</div>`;
    }, "");
    const feedback_tabs = feedback_names.reduce((acc, curr) => {
      return acc + /*html*/`<div>${curr}</div>`;
    }, "");

    console.log(feedback_tabs);



    //const component = generate_component().innerHtml;

    template.innerHTML =/*html*/
    `<div id='exercise_tabs' class='tab-viewer'>
      <div class='tabs'>
        <div>Exercise</div>
        <div>Last Submission</div>
      </div>
      <div class='panes'>
        <div>
          <iframe id="description"></iframe>

        </div>
        <div class='last-submission'>
          <span class='description'>Solution for   by  in   </span>
          <div class='submission-status'>
            <span class='material-icons status-icon'>done</span>
            <span>Corect</span>
          </div>

          <div id='feedback_tabs' class='tab-viewer'>
            <div class='tabs'>
              ${feedback_tabs}
              <div>Code</div>
            </div>
            <div class='panes'>
              ${feedback_tables}
              <div>
                <pre class='r'><code>${code}</code></pre>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>`

    template.content.getElementById("description").setAttribute("srcDoc", description);
    return template;
}


// get_status_icon <- function(status, classes){
//   icon <- list(
//     "compilation error" = c(icon, color, secondary),
//     "runtime error" = c(icon, color, ""),
//     "memory limit exceeded" = c(),
//     "time limit exceeded" = c(),
//     "wrong" = c(),
//     "correct" = c(),
//     "queued" = c(),
//     "running" = c(),
//     "internal error" = c(),
//     "unknown" = c()
//   )[[status]]
//   }
