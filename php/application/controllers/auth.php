<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Auth extends CI_Controller {

	public function __construct()
	{
		parent::__construct();
		$this->load->helper('url');
		$this->load->model('admin_model');
	}

	public function index(){
		$this->login();
	}

	public function login(){
		if(isset($this->session->userdata['account'])){
			redirect('/home');
			exit();
		}
		$submit = $this->input->post('submit');
		$account = $this->input->post('account');
		$password = $this->input->post('password');
		if($submit){
			$admin = $this->admin_model->getOne(array('uname'=>$account));
			if(md5($password) == $admin['pwd']){
				$session = array(
					'account' => $account
				);
				$this->session->set_userdata($session);
				echo "right";
			}else{
				echo "wrong";
			}
			exit();
		}
		$this->load->view('auth/login');
	}

	public function logout(){
		$this->session->sess_destroy();
		redirect('/auth/login');
	}
}