export function init_tabs() {
    document.querySelectorAll('.tab-viewer').forEach((tab_view) => {
        console.log("tabviewer found!!!!!!!!!");
        tab_view.querySelectorAll(':scope > .tabs > .tab_header').forEach((btn, index) => {
            btn.addEventListener('click', () => setTab(tab_view, index));
        })
    })
}

export function setTab(tab_view, index) {
    console.log('setTap executed');
    const tabs  = tab_view.querySelector(':scope > .tabs');
    const panes = tab_view.querySelector(':scope > .panes');
    console.log(tabs);
    console.log('step1');
    const prev_active_tab = tabs.querySelector(':scope > .active');
    if(prev_active_tab){
    prev_active_tab.classList.remove('active');
    }
    console.log('step2');
    tabs.querySelectorAll(':scope > .tab_header')[index].classList.add('active');

    console.log('step3');
    const prev_active_pane = panes.querySelector(':scope > .active');
    if(prev_active_pane){
    prev_active_pane.classList.remove('active');
    }
    console.log('step4');
    panes.children[index].classList.add('active');
}