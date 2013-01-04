package architecture;

import java.io.IOException;

public interface TimerEventListener {
	public void onTimerElapsed() throws IOException;
}
