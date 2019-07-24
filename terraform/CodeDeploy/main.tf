provider "aws" {
    # access_key = "ACCESS_KEY_HERE"
    # secret_key = "SECRET_KEY_HERE"
    region = "eu-west-1"
}

resource "aws_iam_user" "cd_iam_usr" {
    name = "code-deploy-user"
    force_destroy = "true"

    tags = {
        Name = "cd-iam-usr"
    }
}

resource "aws_iam_role" "cd_iam_svc_role" {
    name = "iam-cd-service-role"
    assume_role_policy = "${file("cd_iam_svc_plc.json")}"
}

resource "aws_iam_role_policy_attachment" "cd_role_plc" {
    role       = "${aws_iam_role.cd_iam_svc_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_user_policy" "cd_iam_usr_plc" {
    name = "code-deploy-user-policy"
    user = "${aws_iam_user.cd_iam_usr.name}"
    policy = "${file("cd_iam_usr_plc.json")}"
}

resource "aws_codedeploy_app" "cd_web_srv_app" {
    compute_platform = "Server"
    name             = "web-srv-cd-app"
}

resource "aws_sns_topic" "web-srv-cd-sns" {
    name = "web-srv-sns-tpc"
}

resource "aws_codedeploy_deployment_group" "cd_deploy_grp" {
    app_name              = "${aws_codedeploy_app.cd_web_srv_app.name}"
    deployment_group_name = "web-srv-grp"
    service_role_arn      = "${aws_iam_role.cd_iam_svc_role.arn}"

    ec2_tag_set {
        ec2_tag_filter {
            key   = "Name"
            type  = "KEY_AND_VALUE"
            value = "web-srv-inst"
        }
    }

    trigger_configuration {
        trigger_events     = ["DeploymentFailure"]
        trigger_name       = "web-srv-fail"
        trigger_target_arn = "${aws_sns_topic.web-srv-cd-sns.arn}"
    }

    auto_rollback_configuration {
        enabled = true
        events  = ["DEPLOYMENT_FAILURE"]
    }

    alarm_configuration {
        alarms  = ["web-srv-deploy-alarm"]
        enabled = true
    }

    load_balancer_info {
        elb_info {
            name = var.web_server_lb_name
        }   
    }
}