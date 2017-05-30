<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

include_once(APPPATH."core/TT_Controller.php");

class Config extends TT_Controller {

	public function __construct()
	{
		parent::__construct();
		$this->load->helper('url');
		$this->load->model('config_model');
	}

	public function index()
	{
		$data["config"] = $this->config_model->getOne(array('status'=>0));
		$this->load->view('base/header');
		$this->load->view('base/system',$data);
		$this->load->view('base/footer');
	}

	public function edit()
	{
		$params = array(
			'cname' => $this->input->post('cname'),
			'value' => $this->input->post('value')
		);
		$result = $this->config_model->update($params, 1);
		if($result){
			echo 'success';
		}
	}

	public function json()
	{
		$data = $this->config_model->getOne(array('status'=>0));
		$res = array(
			'login' => $data['cname'],
			'file'	=> $data['value']
		);
		echo json_encode($res);
	}
}