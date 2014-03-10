menubar=function(manager)
{
	var aSubmenuData = [
	                    {
	                        id: "routines", 
	                        itemdata: [ 
	                            { text: "Add ...",url:"#add_macro"},
	                            { text: "Delete ...", url:"#delete_macro"},
	                            { text: "View ...", url:"#view_macro"},
	                            { text: "Move ...", url:"#move_macro"}
	                        ]
	                    },
	                    {
	                        id: "connect", 
	                        itemdata: [
							{ 
								text: "Micro", 
                                    submenu: { 
                                        id: "microscope", 
                                        itemdata: [
                                            {text:"Insert",url:"#insert_micro"}, 
          									{text:"Delete",url:"#delete_parcentricity"} 
                                        ] 
                                    }
							},
							{ 
								text: "Parcentricity", 
                                    submenu: { 
                                        id: "Parcentricity", 
                                        itemdata: [
                                            {text:"Insert",url:"#add_parcentricity"}, 
          									{text:"Delete",url:"#delete_parcentricity"} 
                                        ] 
                                    }
							}
							
                            // { text: "Insert Objetive", url:"#insert_objetive"}
	                        ]    
	                    },
	                    {
	                        id: "experiments", 
	                        itemdata: [ 
	                            { text: "Save ...",url:"#save_experiment"},
	                            { text: "Load ...", url:"#load_experiment"}
	                        ]
	                    },
	                    {
	                        id: "utils", 
	                        itemdata: [
                            { text: "Join Templates",url:"#show_join_templates"},
							{ text: "Stitching",url:"#show_stitching",checked:false}
	                        ] 
	                    },
	                    {
	                        id: "admin", 
	                        itemdata: [
							{ 
								text: "Application", 
                                    submenu: { 
                                        id: "application", 
                                        itemdata: [
          									{text:"Reset",url:"#reset_app"} 
                                        ] 
                                    }
							}

							
                            // { text: "Insert Objetive", url:"#insert_objetive"}
	                        ]    
	                    },
	                    // {
	                    //     id: "experiment",
	                    //     itemdata: [
	                    //                             { text: "Load",url:"#load_experiment"},
	                    //                             { text: "Save",url:"#save_experiment"}
	                    //     ]
	                    // },
	                    {
	                        id: "log",
	                        itemdata: [
                            { text: "Show",url:"#show_log"},
                            { text: "Hide",url:"#hide_log"},
	                        ]
	                    }                    
	                ];
	
	

	
	
	var oMenuBar = new YAHOO.widget.MenuBar("barmenu", { 
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


