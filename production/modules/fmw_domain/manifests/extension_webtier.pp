#
# fmw_domain::extension_webtier
#
# Copyright 2015 Oracle. All Rights Reserved
#
class fmw_domain::extension_webtier()
{
  require fmw_domain::domain

  $check = 'webtier.em'

  if $fmw_domain::version in ['12.2.1', '12.2.1.1', '12.2.1.2', '12.1.3', '12.1.2'] {

    if $fmw_domain::version ==  '12.1.2' {
      $restricted           = false
      $wls_em_template      = "${fmw_domain::middleware_home_dir}/em/common/templates/wls/oracle.em_wls_template_12.1.2.jar"
      $wls_webtier_template = "${fmw_domain::middleware_home_dir}/ohs/common/templates/wls/ohs_managed_template_12.1.2.jar"
    }
    elsif $fmw_domain::version ==  '12.1.3' {
      $restricted           = false
      $wls_em_template      = "${fmw_domain::middleware_home_dir}/em/common/templates/wls/oracle.em_wls_template_12.1.3.jar"
      $wls_webtier_template = "${fmw_domain::middleware_home_dir}/ohs/common/templates/wls/ohs_managed_template_12.1.3.jar"
    }
    else {
      if $fmw_domain::restricted == true {
        $restricted           = true
        $wls_em_template      = "${fmw_domain::middleware_home_dir}/em/common/templates/wls/oracle.em_wls_restricted_template.jar"
        $wls_webtier_template = "${fmw_domain::middleware_home_dir}/ohs/common/templates/wls/ohs_jrf_restricted_template.jar"
      }
      else {
        $restricted           = false
        $wls_em_template      = "${fmw_domain::middleware_home_dir}/em/common/templates/wls/oracle.em_wls_template.jar"
        $wls_webtier_template = "${fmw_domain::middleware_home_dir}/ohs/common/templates/wls/ohs_managed_template.jar"
      }
    }
  }
  elsif $fmw_domain::version == '10.3.6' {
    fail('enterprise scheduler is not available on FMW 11g')
  }

  $domain_name                   = $fmw_domain::domain_name
  $adminserver_name              = $fmw_domain::adminserver_name
  $adminserver_listen_address    = $fmw_domain::adminserver_listen_address
  $version                       = $fmw_domain::version

  $repository_database_url       = $fmw_domain::repository_database_url
  $repository_prefix             = $fmw_domain::repository_prefix

  if $::kernel in ['Linux', 'SunOS'] {

    $domain_path       = "${fmw_domain::domains_dir}/${fmw_domain::domain_name}"
    $weblogic_home_dir = $fmw_domain::weblogic_home_dir
    $java_home_dir     = $fmw_domain::java_home_dir
    $domain_dir        = $domain_path
    $app_dir           = "${fmw_domain::apps_dir}/${fmw_domain::domain_name}"
    $tmp_dir           = $fmw_domain::tmp_dir

    file { "${fmw_domain::tmp_dir}/webtier.py":
      ensure  => present,
      content => template('fmw_domain/domain/extensions/webtier.py'),
      mode    => '0755',
      owner   => $fmw_domain::os_user,
      group   => $fmw_domain::os_group,
    }

    if !defined(File[$fmw_domain::apps_dir]) {
      file { $fmw_domain::apps_dir:
        ensure => directory,
        mode   => '0755',
        owner  => $fmw_domain::os_user,
        group  => $fmw_domain::os_group,
      }
    }

    # add webtier
    fmw_domain_wlst{'WLST add webtier':
      ensure              => 'present',
      version             => $fmw_domain::version,
      extension_check     => $check,
      script_file         => "${fmw_domain::tmp_dir}/webtier.py",
      middleware_home_dir => $fmw_domain::middleware_home_dir,
      weblogic_home_dir   => $fmw_domain::weblogic_home_dir,
      java_home_dir       => $fmw_domain::java_home_dir,
      tmp_dir             => $fmw_domain::tmp_dir,
      domain_dir          => $domain_dir,
      repository_password => $fmw_domain::repository_password,
      os_user             => $fmw_domain::os_user,
      require             => File["${fmw_domain::tmp_dir}/webtier.py",$fmw_domain::apps_dir],
    }


  } elsif $::kernel in ['windows'] {

    $domain_path       = fmw_domain_replace_slash("${fmw_domain::domains_dir}/${fmw_domain::domain_name}")
    $weblogic_home_dir = fmw_domain_replace_slash($fmw_domain::weblogic_home_dir)
    $java_home_dir     = fmw_domain_replace_slash($fmw_domain::java_home_dir)
    $domain_dir        = $domain_path
    $app_dir           = fmw_domain_replace_slash("${fmw_domain::apps_dir}/${fmw_domain::domain_name}")
    $tmp_dir           = fmw_domain_replace_slash($fmw_domain::tmp_dir)

    file { "${fmw_domain::tmp_dir}/webtier.py":
      ensure             => present,
      content            => template('fmw_domain/domain/extensions/webtier.py'),
      source_permissions => ignore,
    }

    if !defined(File[$fmw_domain::apps_dir]) {
      file { $fmw_domain::apps_dir:
        ensure => directory,
      }
    }

    # add webtier
    fmw_domain_wlst{'WLST add webtier':
      ensure              => 'present',
      version             => $fmw_domain::version,
      extension_check     => $check,
      script_file         => "${fmw_domain::tmp_dir}/webtier.py",
      middleware_home_dir => $fmw_domain::middleware_home_dir,
      weblogic_home_dir   => $fmw_domain::weblogic_home_dir,
      java_home_dir       => $fmw_domain::java_home_dir,
      tmp_dir             => $fmw_domain::tmp_dir,
      domain_dir          => $domain_dir,
      repository_password => $fmw_domain::repository_password,
      require             => File["${fmw_domain::tmp_dir}/webtier.py",$fmw_domain::apps_dir],
    }

  }

}