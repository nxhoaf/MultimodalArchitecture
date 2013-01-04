package xhrLib;

import java.io.IOException;

public interface MMDispatcherEventListener {
	public void processEvent(MMDispatcherEvent event) throws IOException;
}
