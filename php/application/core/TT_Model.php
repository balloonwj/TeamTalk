<?php (defined('BASEPATH')) OR exit('No direct script access allowed');

class TT_Model extends CI_Model
{

	protected $table_name;

	public function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

	public function insert($data)
	{
		$this->db->insert($this->table_name, $data);
		$id = $this->db->insert_id();
		if ($id) {
			return $id;
		} else {
			return $this->db->affected_rows();
		}
	}

	public function insert_batch($data)
	{
		return $bool = $this->db->insert_batch($this->table_name, $data);
	}

	public function update($data, $id)
	{
		if (is_array($id)) {
			$this->db->where($id, null, false);
		} else {
			$this->db->where('id', $id);
		}
		return $bool = $this->db->update($this->table_name, $data);
	}

	public function updateByWhere($data,$key,$value)
	{
		$this->db->where($key, $value);
		return $bool = $this->db->update($this->table_name, $data);
	}

	public function delete($id, $real = false)
	{
		if ($real) {
			return $bool = $this->_realDelete($id);
		} else {
			$data = array(
				'status' => '-1',
				'edate'  =>	date('Y-m-d H:i:s')
			);
			return $bool = $this->update($data, $id);
		}
	}

	private function _realDelete($id)
	{
		if (is_array($id)) {
			$this->db->where($id, null, false);
		} else {
			$this->db->where('id', $id);
		}
		return $bool = $this->db->delete($this->table_name);
	}

	public function getOne($params = array(), $fields = '*')
	{		
		$q = $this->db->select($fields, false)->where($params)->get($this->table_name);
		return $row = $q->row_array();
	}

	public function getCount($params = array(), $like = array())
	{
		if ( ! isset($params['status'])) {
			$params['status !='] = '-1';
		}
		return $count = $this->db->where($params)->or_like($like)->from($this->table_name)
								 ->count_all_results();
	}

	public function getList($params = array(), $fields = '*', $start = 0, $perpage = 0, 
							$order 	= '', $sort = '', $like = array(), $group = array())
	{
		if ($perpage) {
			$this->db->limit($perpage, $start);
		}
		if ($order && $sort) {
			$this->db->order_by($order, $sort);
		}
		if (!empty($group) && count($group) > 0) {
			$this->db->group_by($group);
		}		
		$q = $this->db->select($fields, false)->where($params)->or_like($like)->get($this->table_name);
		return $list = $q->result_array();
	}

	public function getLike($like = array(), $params = array(), $fields = '*', 
							$start = 0, $perpage = 0, $order = '', $sort = '')
	{
		return $list = $this->getList($params, $fields, $start, $perpage, $order, $sort, $like);
	}

	public function getIn($inField, $inArray, $params = array(), $fields = '*', 
						  $start = 0, $perpage = 0, $order = '', $sort = '')
	{
		if ( empty($inArray) ) {
			return array();
		}
		$inString = implode(',', $inArray);
		$params["$inField in ($inString)"] = null;
		return $list = $this->getList($params, $fields, $start, $perpage, $order, $sort);
	}

	public function getInCount($inField, $inArray, $params = array())
	{
		if ( empty($inArray) ) {
			return 0;
		}
		$list = $this->getIn($inField, $inArray, $params, $fields=' count(*) as num ');
		if (isset($list[0]['num'])) {
			return $count = intval($list[0]['num']);
		} else {
			return 0;
		}
	}

	public function getQuery($sql)
	{
		return $list = $this->db->query($sql)->result_array();
	}
}
