generate_html <- function(data, exercise_tab=0, feedback_tab=0) {
    paste0('
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
        <link rel="stylesheet" href="./style.css">
        <link rel="stylesheet" href="./lib/highlight_Vs.css">
        <script src="./lib/highlight.min.js"></script>
        <script src="https://code.iconify.design/2/2.2.0/iconify.min.js"></script>
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <link rel="stylesheet" media="all" href="https://dodona.ugent.be/assets/application-7a8bece9578bc7a116704c6b0c16fc4b2e56c6b0dcb02faece8b98f3cb0629b8.css">
    </head>
    <body class="body">
        <script type="module">
            import {dodona_lite} from "./app.js"
            import {init_tabs, setTab} from "./tabs.js"
            document.body.appendChild(dodona_lite(', jsonlite::toJSON(data, null = "null"), ').content.cloneNode(true));

            init_tabs();
            hljs.configure({languages: ["r"]});
            hljs.highlightAll();

            console.log(document.querySelector("#exercise_tabs"));
            setTab(document.querySelector("#exercise_tabs"), ', exercise_tab, ');
            setTab(document.querySelector("#feedback_tabs"), ', feedback_tab, ');
        </script>
    </body>
    </html>')
}



