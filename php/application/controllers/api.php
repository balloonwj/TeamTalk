<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Api extends CI_Controller {

	public function __construct()
	{
		parent::__construct();
		$this->load->helper('url');
		$this->load->model('discovery_model');
	}

	public function discovery()
	{
		$data = $this->discovery_model->getList(array('status'=>0));
		foreach ($data as $key => $value) {
			unset($data[$key]['id']);
			unset($data[$key]['status']);
			unset($data[$key]['created']);
			unset($data[$key]['updated']);
		}
		echo json_encode($data);
	}
}