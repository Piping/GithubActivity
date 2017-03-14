package ecs189.querying.github;

import ecs189.querying.Util;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by Vincent on 10/1/2017.
 */
public class GithubQuerier {

    private static final String BASE_URL = "https://api.github.com/users/";

    public static String eventsAsHTML(String user) throws IOException, ParseException {
        List<JSONObject> response = getEvents(user);
        StringBuilder sb = new StringBuilder();
        sb.append("<div>");
        int i = 0;
        for (JSONObject event : response) {
            // Get event type
            String type = event.getString("type");
            // Get created_at date, and format it in a more pleasant style
            String creationDate = event.getString("created_at");
            SimpleDateFormat inFormat = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ss'Z'");
            SimpleDateFormat outFormat = new SimpleDateFormat("dd MMM, yyyy");
            Date date = inFormat.parse(creationDate);
            String formatted_data = outFormat.format(date);

            //Make the webpage
            // Add type of event as header
            sb.append("<h3 class=\"type\">" + type + "</h3>");
            // Add formatted date
            sb.append(" on " + formatted_data);
            sb.append("<br />");

            //Get commit message and SHA1
            JSONArray commits = event.getJSONObject("payload").getJSONArray("commits");
            System.out.println(commits);
            String hash = "";
            String msg="";
            for(int k =0; k< commits.length();k++){
                JSONObject commit = commits.getJSONObject(k);
                hash = commit.getString("sha");
                msg = commit.getString("message");
                // Add sha and message
                sb.append("SHA: "+hash.substring(0,8));
                sb.append("<br />");
                sb.append("Commit Message: "+msg);
                sb.append("<br />");
            }
            // Add collapsible JSON textbox (don't worry about this for the homework; it's just a nice CSS thing I like)
            sb.append("<a data-toggle=\"collapse\" href=\"#event-" + i + "\">Detailed JSON Info</a>");
            sb.append("<div id=event-" + i + " class=\"collapse\" style=\"height: auto;\"> <pre>");
            sb.append(event.toString());
            sb.append("</pre> </div>");
        }
        sb.append("</div>");
        return sb.toString();
    }


    private static List<JSONObject> getEvents(String user) throws IOException {
        List<JSONObject> eventList = new ArrayList<JSONObject>();

        JSONArray events;
        int page = 1;
        do {
            String url = BASE_URL + user + "/events?page="+page;
            System.out.println(url);
            JSONObject json = Util.queryAPI(new URL(url));
            //System.out.println(json);
            events = json.getJSONArray("root");
            for (int i = 0; i < events.length() && i < 10; i++) {
                JSONObject single_event = events.getJSONObject(i);
                //System.out.println(single_event.getString("type"));
                if( single_event.getString("type").equals("PushEvent")){
                    eventList.add(single_event);
                }
            }
            System.out.println(eventList);
            //System.out.println(page);
            page += 1;
        }while(events.length()!=0);

        return eventList;
    }
}