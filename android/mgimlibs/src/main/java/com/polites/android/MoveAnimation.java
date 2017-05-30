package com.polites.android;

public class MoveAnimation implements Animation {

	private boolean firstFrame = true;

	private float startX;
	private float startY;

	private float targetX;
	private float targetY;
	private long animationTimeMS = 100;
	private long totalTime = 0;

	private MoveAnimationListener moveAnimationListener;

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.polites.android.Animation#update(com.polites.android.GestureImageView
	 * , long)
	 */
	@Override
	public boolean update(GestureImageView view, long time) {
		totalTime += time;

		if (firstFrame) {
			firstFrame = false;
			startX = view.getImageX();
			startY = view.getImageY();
		}

		if (totalTime < animationTimeMS) {

			float ratio = (float) totalTime / animationTimeMS;

			float newX = ((targetX - startX) * ratio) + startX;
			float newY = ((targetY - startY) * ratio) + startY;

			if (moveAnimationListener != null) {
				moveAnimationListener.onMove(newX, newY);
			}

			return true;
		} else {
			if (moveAnimationListener != null) {
				moveAnimationListener.onMove(targetX, targetY);
			}
		}

		return false;
	}

	public void reset() {
		firstFrame = true;
		totalTime = 0;
	}

	public float getTargetX() {
		return targetX;
	}

	public void setTargetX(float targetX) {
		this.targetX = targetX;
	}

	public float getTargetY() {
		return targetY;
	}

	public void setTargetY(float targetY) {
		this.targetY = targetY;
	}

	public long getAnimationTimeMS() {
		return animationTimeMS;
	}

	public void setAnimationTimeMS(long animationTimeMS) {
		this.animationTimeMS = animationTimeMS;
	}

	public void setMoveAnimationListener(
			MoveAnimationListener moveAnimationListener) {
		this.moveAnimationListener = moveAnimationListener;
	}
}
