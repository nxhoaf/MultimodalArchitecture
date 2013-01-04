package main;

import java.util.Date;
import java.util.List;
import javax.swing.table.DefaultTableModel;

import architecture.ComplexMc;
import architecture.Controller;
import architecture.InteractionEvent;
import architecture.InteractionEventListener;
import architecture.MCFactory;

import utilities.ConfigurationReader;
import utilities.Loggable;

/**
 * 
 * @author nxhoaf
 */
public class MainMenu extends java.awt.Frame implements
		InteractionEventListener, Loggable {
	private javax.swing.JButton back;
	private javax.swing.JLabel dateLabel;
	private javax.swing.JPanel jPanel3;
	private javax.swing.JPanel jPanel4;
	private javax.swing.JScrollPane jScrollPane1;
	private javax.swing.JButton next;
	private javax.swing.JTable table;
	private List<DailyData> dailyDataList;
	int currentElement;
	private Controller controller;

	private static MainMenu mainMenu;

	/**
	 * Creates new form MainMenu
	 */
	public MainMenu() {

		// Init the front end
		initComponents();
		this.setSize(550, 600);

		// Init the back end system.
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		String componentName = localConf.getString("componentName",
				"MC_JavaComponent");
		ComplexMc complexMc = MCFactory.createComplexMc(componentName);
		controller = complexMc.getController();
		controller.addEventListener(this);

		// Populating the data
		dailyDataList = XMLParser.parseXmlFile("config/schedulingInfo.xml");
		DailyData dailyData = dailyDataList.get(0);
		currentElement = 0;

		// Update date
		Date date = dailyData.getDate();
		String dateInfo = date.toString();
		dateLabel.setText(dateInfo);

		updateButtonVisibility();
		fillTable(dailyData);
	}

	public void load() {
		controller.load();
	}

	private void updateButtonVisibility() {
		if (currentElement == 0) {
			back.setEnabled(false);
		} else {
			back.setEnabled(true);
		}

		if (currentElement == dailyDataList.size() - 1) {
			next.setEnabled(false);
		} else {
			next.setEnabled(true);
		}
	}

	private void fillTable(DailyData dailyData) {
		DefaultTableModel dtModel = new DefaultTableModel();
		dtModel.addColumn("Hour");
		dtModel.addColumn("Room");
		dtModel.addColumn("Description");

		String[] row = new String[3];
		List<Event> events = dailyData.getEvents();
		for (int i = 0; i < events.size(); i++) {
			Event event = events.get(i);
			row[0] = event.getStartHour() + "h - " + event.getEndHour() + "h";
			row[1] = event.getRoom();
			row[2] = event.getDescription();

			dtModel.addRow(row);
		}

		table.setModel(dtModel);
	}

	private void initComponents() {

		jPanel3 = new javax.swing.JPanel();
		back = new javax.swing.JButton();
		dateLabel = new javax.swing.JLabel();
		next = new javax.swing.JButton();
		jPanel4 = new javax.swing.JPanel();
		jScrollPane1 = new javax.swing.JScrollPane();
		table = new javax.swing.JTable();

		addWindowListener(new java.awt.event.WindowAdapter() {
			public void windowClosing(java.awt.event.WindowEvent evt) {
				exitForm(evt);
			}
		});
		setLayout(null);

		jPanel3.setLayout(null);

		back.setText("Back");
		back.setName("back"); // NOI18N
		back.addActionListener(new java.awt.event.ActionListener() {
			public void actionPerformed(java.awt.event.ActionEvent evt) {
				backActionPerformed(evt);
			}
		});
		jPanel3.add(back);
		back.setBounds(10, 10, 80, 20);

		dateLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		dateLabel.setText("Date");
		jPanel3.add(dateLabel);
		dateLabel.setBounds(100, 10, 320, 20);
		dateLabel.getAccessibleContext().setAccessibleName("label");

		next.setText("Next");
		next.setName("next"); // NOI18N
		next.addActionListener(new java.awt.event.ActionListener() {
			public void actionPerformed(java.awt.event.ActionEvent evt) {
				nextActionPerformed(evt);
			}
		});
		jPanel3.add(next);
		next.setBounds(425, 10, 70, 23);

		add(jPanel3);
		jPanel3.setBounds(10, 30, 510, 40);

		table.setModel(new javax.swing.table.DefaultTableModel(new Object[][] {
				{ null, null, null, null }, { null, null, null, null },
				{ null, null, null, null }, { null, null, null, null } },
				new String[] { "Title 1", "Title 2", "Title 3", "Title 4" }));
		table.setName(""); // NOI18N
		jScrollPane1.setViewportView(table);

		jPanel4.add(jScrollPane1);

		add(jPanel4);
		jPanel4.setBounds(10, 80, 510, 450);

		pack();
	}

	/**
	 * Exit the Application
	 */
	private void exitForm(java.awt.event.WindowEvent evt) {
		System.exit(0);
	}

	private void nextActionPerformed(java.awt.event.ActionEvent evt) {
		// TODO add your handling code here:
		currentElement++;

		updateButtonVisibility();
		;
		DailyData dailyData = dailyDataList.get(currentElement);

		// Update date
		Date date = dailyData.getDate();
		String dateInfo = date.toString();
		dateLabel.setText(dateInfo);

		fillTable(dailyData);

	}

	private void backActionPerformed(java.awt.event.ActionEvent evt) {
		currentElement--;

		updateButtonVisibility();
		;
		DailyData dailyData = dailyDataList.get(currentElement);

		// Update date
		Date date = dailyData.getDate();
		String dateInfo = date.toString();
		dateLabel.setText(dateInfo);

		fillTable(dailyData);
	}

	/**
	 * @param args
	 *            the command line arguments
	 */
	public static void main(String args[]) {
		mainMenu = new MainMenu();
		mainMenu.load();
	}

	@Override
	public void processInteractionEvent(InteractionEvent event) {
		// TODO Auto-generated method stub
		String eventName = event.getName();

		if (eventName.equals(InteractionEvent.BEFORE_NEW_CTX_REQUEST_SENT)) {
			log("[MainMenu]{BEFORE_NEW_CTX_REQUEST_SENT}");
		} else if (eventName.equals(InteractionEvent.ON_NEW_CTX_REQUEST_SENT)) {
			log("[MainMenu]{ON_NEW_CTX_REQUEST_SENT}");
		} else if (eventName.equals(InteractionEvent.ON_HAVING_CONTEXT)) {
			log("[MainMenu]{ON_HAVING_CONTEXT}");

			mainMenu.setVisible(true);
			back.setVisible(false);
			next.setVisible(false);
			table.setVisible(false);
			dateLabel
					.setText("Application ready, waiting for start request...");
			controller.switchToPullMode();
			
		} else if (eventName.equals(InteractionEvent.ON_PROCESS_START_REQUEST)) {
			log("[MainMenu]{ON_PROCESS_START_REQUEST}");
			back.setVisible(true);
			next.setVisible(true);
			table.setVisible(true);

			// Populating the data
			DailyData dailyData = dailyDataList.get(0);
			currentElement = 0;

			// Update date
			Date date = dailyData.getDate();
			String dateInfo = date.toString();
			dateLabel.setText(dateInfo);

			updateButtonVisibility();
			fillTable(dailyData);

		} else if (eventName.equals(InteractionEvent.ON_PROCESS_PAUSE_REQUEST)) {

		} else if (eventName.equals(InteractionEvent.ON_PROCESS_RESUME_REQUEST)) {

		} else if (eventName.equals(InteractionEvent.ON_PROCESS_CANCEL_REQUEST)) {
			log("[MainMenu]{ON_PROCESS_CANCEL_REQUEST}");
			mainMenu.setVisible(false);
		} else {
			log("[MainMenu]{processInteractionEvent} - Default: "
					+ event.getName());
		}
	}

	@Override
	public void log(String message) {
		// TODO Auto-generated method stub
		System.out.println(message);
	}
}
