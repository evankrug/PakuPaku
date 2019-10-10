var makeup = function(){
    return(
        <div className="expansion_table_group">
            <ExpansionTable title="Makeup" dataObj={makeupData.Makeup} />
            <ExpansionTable title="Lashes" dataObj={makeupData.Lashes}/>
        </div>
    );
};

ReactDOM.render(
    makeup(),
    document.getElementById("makeup_panel")
);

$('#makeup_pricing_msg').text(getPricingMsg());