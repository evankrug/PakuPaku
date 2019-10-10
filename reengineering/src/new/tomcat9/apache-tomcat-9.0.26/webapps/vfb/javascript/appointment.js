ReactDOM.render(
    <AppointmentStepper/>,
    document.getElementById('appointment_stepper')
);

var renderCalendar = function() {
    var calendarEl = document.getElementById('appointment_calendar');
    var calendar = new FullCalendar.Calendar(calendarEl, {
        plugins: ['dayGrid', 'interaction'],
        header: {
            left: '',
            center: 'title',
            right: 'prev,next'
        },
        dateClick: info => { calendar.select(info.date); },
        validRange: today => {
            return {
                start: today,
                end: addMonths(today, 2)
            };
        },
        height: 'parent',
        contentHeight: 'auto',
        dragScroll: false,
        disableDragging: true,
        defaultView: 'dayGridMonth',
        showNonCurrentDates: false
    });
    calendar.render();
};

function addMonths(dateStr, n) {
    var date = new Date(dateStr);
    var month = date.getMonth() + n + 1;
    var day = 1;
    return new Date(date.getFullYear(), month, day);
};