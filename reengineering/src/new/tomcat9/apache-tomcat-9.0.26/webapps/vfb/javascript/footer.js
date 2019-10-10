var footer = function() {
    return (
        <AppBar position="static"
                className="footer_bar">
            <Tooltip title="Find us on Facebook" enterDelay={800}>
                <img id="facebook_button" src="../resources/images/stylized_facebook.svg" alt="facebook_logo" className="social_media_icon facebook_logo"/>
            </Tooltip>
            <Tooltip title="Checkout our Instagram" enterDelay={800}>
                <img id="instagram_logo" src="../resources/images/instagram_icon.svg" alt="instagram_logo" className="social_media_icon instagram_logo"/>
            </Tooltip>
            <Tooltip title="Find us on Google Maps" enterDelay={800}>
                <i id="google_maps" className="material-icons text_icon_logo social_media_icon">place</i>
            </Tooltip>
            <Tooltip title="Call Us" enterDelay={800}>
                <i id="call" className="material-icons text_icon_logo social_media_icon">local_phone</i>
            </Tooltip>
            <Tooltip title="Email US" enterDelay={800}>
                <i id="email" className="material-icons text_icon_logo social_media_icon">email</i>
            </Tooltip>
        </AppBar>
    );
};

ReactDOM.render(
    footer(),
    document.getElementById("footer")
);


//Button Click Handlers
$('#facebook_button').click(function(){
    window.location.href = links.facebook;
});

$('#instagram_logo').click(function(){
    window.location.href = links.instagram;
});

$('#google_maps').click(function(){
    window.location.href = links.google_maps;
});

$('#call').click(function(){
    window.location.href = "tel:" + contactInfo.phone_number;
});

$('#email').click(function(){
    window.location.href = "mailto:" + contactInfo.email;
});