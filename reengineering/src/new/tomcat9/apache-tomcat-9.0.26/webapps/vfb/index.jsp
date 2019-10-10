<html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- jQuery -->
        <script type="text/javascript" src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
        <script type="text/javascript" src= "https://cdnjs.cloudflare.com/ajax/libs/jquery-migrate/3.0.1/jquery-migrate.min.js"></script>

        <!-- Includes to make REACT function -->
        <script type="application/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/6.26.0/babel.js" charset="UTF-8"></script>
        <script crossorigin src="https://unpkg.com/react@16/umd/react.development.js"></script>
        <script crossorigin src="https://unpkg.com/react-dom@16/umd/react-dom.development.js"></script>
        <script type="application/javascript" src="https://unpkg.com/@material-ui/core@3.9.3/umd/material-ui.development.js"></script>
        <script src="https://unpkg.com/react-day-picker/lib/daypicker.min.js"></script>
        <script type="text/babel" data-presets="es2015,stage-2"></script>

        <!-- Fonts -->
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons"  rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">

        <!-- TODO: Write an import function for js and css files, similar SMS's WebIncludeManager -->

        <!-- Slider imports -->
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/slick-carousel/1.9.0/slick.css"/>
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/slick-carousel/1.9.0/slick-theme.css"/>
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/slick-carousel/1.9.0/slick.min.js"></script>
        <script type="application/javascript" src="javascript/slider.js"></script>

        <!-- FullCalendar imports -->
        <link href='fullcalendar-4.1/core/main.css' rel='stylesheet' />
        <link href='fullcalendar-4.1/daygrid/main.css' rel='stylesheet' />
        <script src='fullcalendar-4.1/core/main.js'></script>
        <script src='fullcalendar-4.1/daygrid/main.js'></script>
        <script src='fullcalendar-4.1/interaction/main.js'></script>

        <!-- CSS Includes -->
        <link href="reactElements/ExpansionTable.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="https://unpkg.com/react-day-picker/lib/style.css">
        <link href="css/app.css" rel="stylesheet" type="text/css">
        <link href="css/header.css" rel="stylesheet" type="text/css">
        <link href="css/footer.css" rel="stylesheet" type="text/css">
        <link href="css/body.css" rel="stylesheet" type="text/css">
        <link href="css/slider.css" rel="stylesheet" type="text/css">
        <link href="css/about.css" rel="stylesheet" type="text/css">
        <link href="css/appointment.css" rel="stylesheet" type="text/css">


        <!-- javaScript includes-->
        <script type="application/javascript" src="javascript/util.js"></script>
        <script type="application/javascript" src="reactElements/MobileMenu.js"></script>
        <script type="application/javascript" src="reactElements/MenuButtons.js"></script>
        <script type="text/babel" src="reactElements/ExpansionTable.js"></script>
        <script type="text/babel" src="javascript/stepper.js"></script>
        <script type="text/babel" src="javascript/appointment.js"></script>
        <script type="text/babel" src="javascript/header.js"></script>
        <script type="text/babel" src="javascript/footer.js"></script>
        <script type="text/babel" src="javascript/hair.js"></script>
        <script type="text/babel" src="javascript/makeup.js"></script>


        <title>Volte-Face Beauty</title>
    </head>
    <body class="body" style="width:100%">
        <div id="header" style="width:100%;"></div>
        <div id="home" class="content_div"></div>
        <div id="hair" class="content_div hidden overflow_y center_content"></div>
        <div id="makeup" class="content_div hidden overflow_y center_content" ></div>
        <div id="appointment" class="content_div hidden overflow_y center_content"></div>
        <div id="store" class="content_div hidden" style="background-color: pink"></div>
        <div id="about" class="content_div hidden overflow_y"></div>
        <div id="login" class="content_div hidden" style="background-color: black"></div>
        <div id="footer"></div>
    </body>
</html>

<script type="text/javascript">
    $("#home").load("/html/slider.html");
    $("#hair").load("/html/hair.html");
    $("#makeup").load("/html/makeup.html");
    $("#appointment").load("/html/appointment.html");
    //$("#store").load("/html/store.html");
    $("#about").load("/html/about.html");
    //$("#login").load("/html/login.html");
</script>


