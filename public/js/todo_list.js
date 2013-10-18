$(document).ready(function(){
	$(".done").click(function(e){
		var item_id = $(this).parents('li').attr('id');
		$.ajax({
			type: "POST",
			url: "/done",
			data: { id: item_id},
		}).done(function(data){
			if(data.status == 'done'){
				$("#" + data.id + "a.done").text('Not done')
				$("#" + data.id + ".item").wrapInner("<del>");
			}
			else{
				$("#" + data.id + "a.done").text('Done')
				$("#" + data.id + ".item").html(function(i, h){
					return h.replace("<del>", "");
				});
			}
		});
		e.preventDefault();
	});
});




/*

jQuery is utilised for this Ajax call. You will notice 
that it’s a fairly standard Ajax POST call to the /done route. 
The to-do item id is fetched from the <li> tag and passed 
as JSON in the post request. After the Ajax call has come 
back as done, the data that’s sent back from Sinatra is 
used to change the name of the button and add or remove 
the <del> tags from the text as required.
*/