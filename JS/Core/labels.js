var imrc_labels={
	'menu':
			[
				{
					title:'Image analysis routines',
					submenu:[
						{
							title:'Add ...'
						},
						{
							title:'Delete ...'
						},
						{
							title:'View ...'
						},
						{
							title:'Move ...'
						}
					]
				},
				{
					title:'Microscope',
					submenu:[
							{
								title:'Micro',
								submenu:[
											{
												title:'Insert ...'
											},
											{
												title:'Delete ...'
											}
										]
							},
							{
								title:'Paracentricity',
								submenu:[
											{
												title:'Insert ...'
											},
											{
												title:'Delete ...'
											}
										]
							}
						]
				},
				{
					title:'Experiment',
					submenu:[
						{
							title:'Save ...'
						},
						{
							title:'Load ...'
						}
					]
				},
				{
					title:'Tools',
					submenu:[
						{
							title:'Join Templates ...'
						},
						{
							title:'Stitching'
						}
					]
				},
				{
					title:'Admin',
					submenu:[
							{
								title:'Application',
								submenu:[
											{
												title:'Reset'
											}
										]
							},
							{
								title:'Log',
								submenu:[
											{
												title:'Show'
											},
											{
												title:'Hide'
											}
										]
							}
						]
				},
				{
					title:'Play'
				}
				
			]
	,
	'micro':{
				title:'Select Microscope:',
				button1:'Refresh',
				label1:'Low Resolution Images Folder:',
				label2:'Select Experiment:'
	},
	'step1':{
				title:'1st SCAN',
				button1:'Run Autofocus & Play',
				button2:{on:'Autofocus: On',off:'Autofocus: Off'},
				button3:'Low resolution Image',
				label1:'Select Low Resolution Scan Settings:'
	},
	'imagej':{
				title:'2nd SCAN',
				button1:{on:'NoIR: On',off:'NoIR: Off'},
				button2:{on:'Coordinete correction: On',off:'Coordinete correction: Off'},
				button3:'Advanced Options',
				button4:'Analyze images',
				button5:'View detected images',
				button6:'Change sample',
				label1: 'Select objects detection routine',
				label2:'Select template 2:',
				label3: 'Select NoIR',
				advanced:{
					title:'Advanced options',
					label1:'Intensity:&nbsp;',
					label2:'Size:&nbsp;',
					label3:'Circulary:&nbsp;',
					button1:'ok',
					button2:'Refresh'
						}
	},
	'high':{
				title:'Scan Launcher',
				button1:{on:'Autofocus: On',off:'Autofocus: Off'},
				button2:'Run high scanning',
				label1: 'Scan all templates',
				label2:'Select template:'
	},
	'stitching':{
				title:'Stiching',
				button1:'View',
				button2:'Stiching',
				label1: 'Select macro',
				label2:'Select code color:',
				label3:'Select images:'
				
	},
	'addmacro':{
				title:'Add macro',
				button1:'Save',
				button2:'Cancel',
				label1: 'Select macro file: ',
				select:{
					title:'Type of macros',
					options:[
								{value:'detect',text:'Objects detection'},
								{value:'blacks',text:'Remove Non Informative Areas'},
								{value:'stitching',text:'Mosaic images stitching'}
							]
						}
				
	},
	'addmicrospe':{
				title:'Add microscope',
				label1:'Step 1: Name',
				label2:'Step 2: File&#39;s directories',
				label3:'Step 3: Credentials',
				label4:'Microscope&#39;s name',
				label5:'Microscope&#39;s computer IP address:',
				label6:'Microscope&#39;s computer shared images folder:',
				label7:'Microscope&#39;s computer images folder:',
				label8:'Microscope&#39;s computer shared templates folder:',
				label9:'Microscope&#39;s computer templates folder:',
				label10:'Microscope&#39;s computer user&#39;s name:',
				label11:'Microscope&#39;s computer user&#39;s password:',
				label12:'Images (Case Sensitive)',
				label13:'Templates (Case Sensitive)',
				button1:'Cancel',
				button2:'Next',
				button3:'Finish and Reload Page'
		}
	
};



