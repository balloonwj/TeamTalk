
package com.mogujie.tt.ui.adapter.album;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.provider.MediaStore.Audio.Albums;
import android.provider.MediaStore.Images.Media;
import android.provider.MediaStore.Images.Thumbnails;

import com.mogujie.tt.utils.Logger;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

/**
 * @Description 相册相关处理
 * @author Nana
 * @date 2014-5-6
 */
public class AlbumHelper {
    Context context = null;
    ContentResolver contentResolver = null;

    // 缩略图列表
    HashMap<String, String> thumbnailList = new HashMap<String, String>();
    List<HashMap<String, String>> albumList = new ArrayList<HashMap<String, String>>();
    HashMap<String, ImageBucket> bucketList = new HashMap<String, ImageBucket>();
    private Logger logger = Logger.getLogger(AlbumHelper.class);

    private static AlbumHelper instance = null;

    private AlbumHelper(Context cxt) {
        if (null == this.context && null != cxt) {
            this.context = cxt;
            contentResolver = context.getContentResolver();
        }
    }

    public static AlbumHelper getHelper(Context cxt) {
        if (null == instance) {
            instance = new AlbumHelper(cxt);
        }
        return instance;
    }

    /**
     * 得到缩略图
     */
    private void getThumbnail() {
        String[] projection = {
                Thumbnails._ID, Thumbnails.IMAGE_ID,
                Thumbnails.DATA
        };
        Cursor cursor = null;
        try {
            cursor = contentResolver.query(Thumbnails.EXTERNAL_CONTENT_URI,
                    projection, null, null, null);
            getThumbnailColumnData(cursor);
        } catch (Exception e) {
            logger.e(e.getMessage());
        } finally {
            if (null != cursor) {
                cursor.close();
            }
        }
    }

    /**
     * 从数据库中得到缩略图
     * 
     * @param cur
     */
    private void getThumbnailColumnData(Cursor cur) {
        try {
            if (null == cur)
                return;
            if (cur.moveToFirst()) {
                @SuppressWarnings("unused")
                int cId;
                int image_id;
                String image_path;
                int _idColumn = cur.getColumnIndex(Thumbnails._ID);
                int image_idColumn = cur.getColumnIndex(Thumbnails.IMAGE_ID);
                int dataColumn = cur.getColumnIndex(Thumbnails.DATA);

                do {
                    cId = cur.getInt(_idColumn);
                    image_id = cur.getInt(image_idColumn);
                    image_path = cur.getString(dataColumn);
                    thumbnailList.put("" + image_id, image_path);
                } while (cur.moveToNext());
            }
        } catch (Exception e) {
            logger.e(e.getMessage());
        }
    }

    /**
     * @Description 得到原图
     */
    @SuppressWarnings("unused")
    private void getAlbum() {
        String[] projection = {
                Albums._ID, Albums.ALBUM, Albums.ALBUM_ART,
                Albums.ALBUM_KEY, Albums.ARTIST, Albums.NUMBER_OF_SONGS
        };
        Cursor cursor = null;
        try {
            cursor = contentResolver.query(Albums.EXTERNAL_CONTENT_URI,
                    projection, null, null, null);
            getAlbumColumnData(cursor);
        } catch (Exception e) {
            logger.e(e.getMessage());
        } finally {
            if (null != cursor) {
                cursor.close();
            }
        }

    }

    /**
     * 从数据库中得到原图
     * 
     * @param cur
     */
    private void getAlbumColumnData(Cursor cur) {
        try {
            if (cur.moveToFirst()) {
                int _id;
                String album;
                String albumArt;
                String albumKey;
                String artist;
                int numOfSongs;

                int _idColumn = cur.getColumnIndex(Albums._ID);
                int albumColumn = cur.getColumnIndex(Albums.ALBUM);
                int albumArtColumn = cur.getColumnIndex(Albums.ALBUM_ART);
                int albumKeyColumn = cur.getColumnIndex(Albums.ALBUM_KEY);
                int artistColumn = cur.getColumnIndex(Albums.ARTIST);
                int numOfSongsColumn = cur.getColumnIndex(Albums.NUMBER_OF_SONGS);

                do {
                    _id = cur.getInt(_idColumn);
                    album = cur.getString(albumColumn);
                    albumArt = cur.getString(albumArtColumn);
                    albumKey = cur.getString(albumKeyColumn);
                    artist = cur.getString(artistColumn);
                    numOfSongs = cur.getInt(numOfSongsColumn);
                    HashMap<String, String> hash = new HashMap<String, String>();
                    hash.put("_id", _id + "");
                    hash.put("album", album);
                    hash.put("albumArt", albumArt);
                    hash.put("albumKey", albumKey);
                    hash.put("artist", artist);
                    hash.put("numOfSongs", numOfSongs + "");
                    albumList.add(hash);
                } while (cur.moveToNext());

            }
        } catch (Exception e) {
            logger.e(e.getMessage());
        }
    }

    // 是否创建图片集
    boolean hasBuildImagesBucketList = false;

    /**
     * @Description 获取图片集
     */
    private void buildImagesBucketList() {
    	bucketList.clear();
        Cursor cur = null;
        // long startTime = System.currentTimeMillis();
        try {
            // 构造缩略图索引
            getThumbnail();

            // 构造相册索引
            String columns[] = new String[] {
                    Media._ID, Media.BUCKET_ID,
                    Media.PICASA_ID, Media.DATA, Media.DISPLAY_NAME, Media.TITLE,
                    Media.SIZE, Media.BUCKET_DISPLAY_NAME
            };

            // 得到一个游标
            cur = contentResolver.query(Media.EXTERNAL_CONTENT_URI, columns,
                    null, null, null);
            if (null == cur)
                return;

            if (cur.moveToFirst()) {
                // 获取指定列的索引
                int photoIDIndex = cur.getColumnIndexOrThrow(Media._ID);
                int photoPathIndex = cur.getColumnIndexOrThrow(Media.DATA);
                // int photoNameIndex =
                // cur.getColumnIndexOrThrow(Media.DISPLAY_NAME);
                // int photoTitleIndex = cur.getColumnIndexOrThrow(Media.TITLE);
                // int photoSizeIndex = cur.getColumnIndexOrThrow(Media.SIZE);
                int bucketDisplayNameIndex = cur
                        .getColumnIndexOrThrow(Media.BUCKET_DISPLAY_NAME);
                int bucketIdIndex = cur.getColumnIndexOrThrow(Media.BUCKET_ID);
                // int picasaIdIndex =
                // cur.getColumnIndexOrThrow(Media.PICASA_ID);
                // 获取图片总数
                @SuppressWarnings("unused")
                int totalNum = cur.getCount();

                do {
                    String id = cur.getString(photoIDIndex);
                    // String name = cur.getString(photoNameIndex);
                    String path = cur.getString(photoPathIndex);
                    // String title = cur.getString(photoTitleIndex);
                    // String size = cur.getString(photoSizeIndex);
                    String bucketName = cur.getString(bucketDisplayNameIndex);
                    String bucketId = cur.getString(bucketIdIndex);
                    // String picasaId = cur.getString(picasaIdIndex);

                    ImageBucket bucket = bucketList.get(bucketId);
                    if (bucket == null) {
                        bucket = new ImageBucket();
                        bucketList.put(bucketId, bucket);
                        bucket.imageList = new ArrayList<ImageItem>();
                        bucket.bucketName = bucketName;
                    }
                    bucket.count++;
                    ImageItem imageItem = new ImageItem();
                    imageItem.setImageId(id);
                    imageItem.setImagePath(path);
                    imageItem.setThumbnailPath(thumbnailList.get(id));
                    bucket.imageList.add(0, imageItem);

                } while (cur.moveToNext());
            }
        } catch (Exception e) {
            logger.e(e.getMessage());
        } finally {
            cur.close();
        }

        try {
            Iterator<Entry<String, ImageBucket>> itr = bucketList.entrySet()
                    .iterator();
            while (itr.hasNext()) {
                Map.Entry<String, ImageBucket> entry = (Map.Entry<String, ImageBucket>) itr
                        .next();
                ImageBucket bucket = entry.getValue();
                for (int i = 0; i < bucket.imageList.size(); ++i) {
                    @SuppressWarnings("unused")
                    ImageItem image = bucket.imageList.get(i);
                }
            }
            hasBuildImagesBucketList = true;
        } catch (Exception e) {
            logger.e(e.getMessage());
        }
    }

    /**
     * 得到图片集
     * @param refresh
     * @return
     */
    public List<ImageBucket> getImagesBucketList(boolean refresh) {
        try {
            if (refresh || (!refresh && !hasBuildImagesBucketList)) {
                buildImagesBucketList();
            }
            List<ImageBucket> imageList = new ArrayList<ImageBucket>(bucketList.values());
            Collections.sort(imageList, new Comparator<ImageBucket>() {

				@Override
				public int compare(ImageBucket lhs, ImageBucket rhs) {
//					logger.d("pic#photo set name:%s", lhs.bucketName);
					boolean lhsDefaultCameraSet = probablyDefaultCameraPhotoSet(lhs.bucketName);
					boolean rhsDefaultCameraSet = probablyDefaultCameraPhotoSet(rhs.bucketName);
					
					logger.d("pic#name:%s, lhsDefaultCameraSet:%s", lhs.bucketName, lhsDefaultCameraSet);
					logger.d("pic#name:%s, rhsDefaultCameraSet:%s", rhs.bucketName, rhsDefaultCameraSet);
					
					if (lhsDefaultCameraSet && !rhsDefaultCameraSet) {
						return -1;
					} 
					
					if (rhsDefaultCameraSet && !lhsDefaultCameraSet) {
						return 1;
					}
					
					return Integer.valueOf(rhs.count).compareTo(Integer.valueOf(lhs.count));
				}
			});
            
            return imageList;
//            List<ImageBucket> tmpList = new ArrayList<ImageBucket>();
//            Iterator<Entry<String, ImageBucket>> itr = bucketList.entrySet()
//                    .iterator();
//            while (itr.hasNext()) {
//                Map.Entry<String, ImageBucket> entry = (Map.Entry<String, ImageBucket>) itr
//                        .next();
//                ImageBucket bucket = entry.getValue();
//                if (bucket.bucketName.equals("Camera")) {
//                    tmpList.onAddMsg(0, bucket);
//                } else {
//                    tmpList.onAddMsg(bucket);
//                }
//            }
//            return tmpList;
        } catch (Exception e) {
            logger.e(e.getMessage());
            return null;
        }
    }

    boolean probablyDefaultCameraPhotoSet(String photoSetName) {
    	//from my test result, different phones use different names to represent 
    	//default photo set
    	if (photoSetName == null || photoSetName.isEmpty()) {
    		return false;
    	}
    	
    	String lowerCaseName = photoSetName.toLowerCase();
    	
    	//todo eric i18n
    	return lowerCaseName.contains("camera") || lowerCaseName.contains("相机");
    }
    
    /**
     * 得到原始图像路径
     * 
     * @param image_id
     * @return
     */
    @SuppressWarnings("unused")
    private String getOriginalImagePath(String image_id) {
        try {
            String path = null;
            String[] projection = {
                    Media._ID, Media.DATA
            };
            Cursor cursor = contentResolver.query(Media.EXTERNAL_CONTENT_URI,
                    projection, Media._ID + "=" + image_id, null, null);
            if (cursor != null) {
                try {
                    cursor.moveToFirst();
                    path = cursor.getString(cursor.getColumnIndex(Media.DATA));
                } catch (Exception e) {
                } finally {
                    cursor.close();
                }
            }
            return path;
        } catch (Exception e) {
            logger.e(e.getMessage());
            return null;
        }
    }

}
