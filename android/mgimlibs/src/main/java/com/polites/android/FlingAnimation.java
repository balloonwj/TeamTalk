package com.polites.android;

public class FlingAnimation implements Animation {

	private float velocityX;
	private float velocityY;

	private float factor = 0.95f;

	private float threshold = 10;

	private FlingAnimationListener listener;

	@Override
	public boolean update(GestureImageView view, long time) {
		float seconds = (float) time / 1000.0f;

		float dx = velocityX * seconds;
		float dy = velocityY * seconds;

		velocityX *= factor;
		velocityY *= factor;

		boolean active = (Math.abs(velocityX) > threshold && Math
				.abs(velocityY) > threshold);

		if (listener != null) {
			listener.onMove(dx, dy);

			if (!active) {
				listener.onComplete();
			}
		}

		return active;
	}

	public void setVelocityX(float velocityX) {
		this.velocityX = velocityX;
	}

	public void setVelocityY(float velocityY) {
		this.velocityY = velocityY;
	}

	public void setFactor(float factor) {
		this.factor = factor;
	}

	public void setListener(FlingAnimationListener listener) {
		this.listener = listener;
	}
}
