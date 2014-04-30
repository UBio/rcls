menubar=function(container,manager)
{
	var menuHTML="<div class='bd'>";
	menuHTML+="<ul class='menu'>";
	menuHTML+="<li class='yuimenubaritem'><a class='yuimenubaritemlabel'>"+imrc_labels['menu'][0]['title']+"</a></li>";
	menuHTML+="<li class='yuimenubaritem'><a class='yuimenubaritemlabel'>"+imrc_labels['menu'][1]['title']+"</a></li>";
	menuHTML+="<li class='yuimenubaritem'><a class='yuimenubaritemlabel'>"+imrc_labels['menu'][2]['title']+"</a></li>";
	menuHTML+="<li class='yuimenubaritem'><a class='yuimenubaritemlabel'>"+imrc_labels['menu'][3]['title']+"</a></li>";
	menuHTML+="<li class='yuimenubaritem'><a class='yuimenubaritemlabel'>"+imrc_labels['menu'][4]['title']+"</a></li>";
	menuHTML+="<li id='control_process'></li>";
	
	menuHTML+="</ul>";
	menuHTML+="</div>";
	
	document.getElementById(container).innerHTML=menuHTML;
	var aSubmenuData = [
	                    {
	                        id: "routines", 
	                        itemdata: [ 
	                            { text: imrc_labels['menu'][0]['submenu'][0]['title'],url:"#add_macro"},
	                            { text: imrc_labels['menu'][0]['submenu'][1]['title'], url:"#delete_macro"},
	                            { text: imrc_labels['menu'][0]['submenu'][2]['title'], url:"#view_macro"},
	                            { text: imrc_labels['menu'][0]['submenu'][3]['title'], url:"#move_macro"}
	                        ]
	                    },
	                    {
	                        id: "connect", 
	                        itemdata: [
							{ 
								text: imrc_labels['menu'][1]['submenu'][0]['title'], 
                                    submenu: { 
                                        id: "microscope", 
                                        itemdata: [
                                            {text:imrc_labels['menu'][1]['submenu'][0]['submenu'][0]['title'],url:"#insert_micro"}, 
          									{text:imrc_labels['menu'][1]['submenu'][0]['submenu'][1]['title'],url:"#delete_micro"} 
                                        ] 
                                    }
							},
							{ 
								text: imrc_labels['menu'][1]['submenu'][1]['title'], 
                                    submenu: { 
                                        id: "Parcentricity", 
                                        itemdata: [
                                            {text:imrc_labels['menu'][1]['submenu'][1]['submenu'][0]['title'],url:"#add_parcentricity"}, 
          									{text:imrc_labels['menu'][1]['submenu'][1]['submenu'][1]['title'],url:"#delete_parcentricity"} 
                                        ] 
                                    }
							}
							
                            // { text: "Insert Objetive", url:"#insert_objetive"}
	                        ]    
	                    },
	                    {
	                        id: "experiments", 
	                        itemdata: [ 
	                            { text: imrc_labels['menu'][2]['submenu'][0]['title'],url:"#save_experiment"},
	                            { text: imrc_labels['menu'][2]['submenu'][1]['title'], url:"#load_experiment"}
	                        ]
	                    },
	                    {
	                        id: "utils", 
	                        itemdata: [
                            { text: imrc_labels['menu'][3]['submenu'][0]['title'],url:"#show_join_templates"},
							{ text: imrc_labels['menu'][3]['submenu'][1]['title'],url:"#show_stitching",checked:false}
	                        ] 
	                    },
	                    {
	                        id: "admin", 
	                        itemdata: [
							{ 
								text: imrc_labels['menu'][4]['submenu'][0]['title'], 
                                    submenu: { 
                                        id: "application", 
                                        itemdata: [
          									{text:imrc_labels['menu'][4]['submenu'][0]['submenu'][0]['title'],url:"#reset_app"} 
                                        ] 
                                    }
							},
							{
								text:imrc_labels['menu'][4]['submenu'][1]['title'],
								submenu:{
								    		id: "log",
											itemdata: [
												{ text: imrc_labels['menu'][4]['submenu'][1]['submenu'][0]['title'],url:"#show_log"},
												{ text: imrc_labels['menu'][4]['submenu'][1]['submenu'][1]['title'],url:"#hide_log"}
												]
								}
							}

							
	                        ]    
	                    }
                   
	                ];
	
	

	
	
	var oMenuBar = new YAHOO.widget.MenuBar(container, { 
	                                                       // autosubmenudisplay: true, 
	                                                       // hidedelay: 750, 
	                                                       lazyload:true,
													   // zindex:5
	 													});
	
	
	oMenuBar.subscribe("beforeRender", function () 
											{
												var nSubmenus = aSubmenuData.length,i;
										        if (this.getRoot() == this)
												{
														for (i = 0; i < nSubmenus; i++) 
														{
										             		this.getItem(i).cfg.setProperty("submenu", aSubmenuData[i]);
														}

										         }

     });
	oMenuBar.render();

	manager.register(oMenuBar);

	oMenuBar.subscribe("click",function(type,args,obj) {
		var submenus=this.getSubmenus();
		for(var i=0;i<submenus.length;i++)
		{
			this.getSubmenus()[i].bringToTop();
		}
	},manager);
	
	this.onClickMenu=new YAHOO.util.CustomEvent("onClickMenuItem",null);
	var me=this;
	oMenuBar.subscribe("click", function(p_sType, p_aArgs) {  

			var oEvent = p_aArgs[0],    // DOM Event
			oMenuItem = p_aArgs[1]; // YAHOO.widget.MenuItem instance
			if (oMenuItem) 
			{
				var url=oMenuItem.cfg.getProperty("url");
				var checked=oMenuItem.cfg.getProperty("checked");
				if(url=='#show_stitching')
				{
					if(checked)
					{
						oMenuItem.cfg.setProperty("checked",false);
					}
					else
					{
						oMenuItem.cfg.setProperty("checked",true);
					}
					checked=oMenuItem.cfg.getProperty("checked");
				}
				me.onClickMenu.fire(url,checked);
			}
		});
		
		
		
		
					
}


