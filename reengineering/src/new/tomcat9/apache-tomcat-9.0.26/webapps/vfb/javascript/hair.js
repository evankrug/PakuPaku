var hair = function(){
    return(
        <div className="expansion_table_group">
            <ExpansionTable title="Haircuts" dataObj={hairData.Haircut} />
            <ExpansionTable title="Coloring" dataObj={hairData.Coloring}/>
            <ExpansionTable title="Texturing" dataObj={hairData.Texture}/>
        </div>
    );
};

ReactDOM.render(
   hair(),
    document.getElementById("hair_panel")
);

$('#hair_pricing_msg').text(getPricingMsg());