generate_exercise_header <- function(exercise, last_sumission){
  return(
    paste0("<style>
      .tab {
        overflow: hidden;
        background-color: #1976d2;
        height: 60px;
      }

      .tab button {
        background-color: inherit;
        border: none;
        outline: none;
        cursor: pointer;
        padding: 14px 16px;
        transition: 0.3s;
        font-size: 17px;
        color: white;
      }

      .tab button:hover {
        background-color: #1660a9;
      }

      .tab button.active {
        background-color: #1660a9;
      }

      .tabcontent {
        display: none;
      }
    </style>


    <div class='tab'>
      <button class='tablinks active' onclick='openTab(event, \'last_submission\')'>Last Submission</button>
      <button class='tablinks'' onclick='openTab(event, \'current_exercise\')'>Exercise</button>
    </div>

    <div id='last_submission' class='tabcontent' style='display:block'>",
    last_sumission,
    "</div>

    <div id='current_exercise' class='tabcontent'>",
    exercise,
    "</div>

    <script>
    function openTab(evt, cityName) {
      var i, tabcontent, tablinks;
      tabcontent = document.getElementsByClassName('tabcontent');
      for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = 'none';
      }
      tablinks = document.getElementsByClassName('tablinks');
      for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(' active', '');
      }
      document.getElementById(cityName).style.display = 'block';
      evt.currentTarget.className += ' active';
    }
    </script>")
  )
}
