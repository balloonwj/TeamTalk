<?php (defined('BASEPATH')) OR exit('No direct script access allowed');

class TT_Controller extends CI_Controller {

	function __construct()
	{
		parent::__construct();
		if(!isset($this->session->userdata['account'])){
			$this->load->helper('url');
			redirect('/auth/login');
		}
	}
}	


