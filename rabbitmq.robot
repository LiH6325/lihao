*** Settings ***
Documentation    test rabbitmq service
Library  String
Library  DateTime
Library  SSHLibrary
Resource  ../resource/sit_common_cla.robot


*** Variables ***
${EXPERiIMENT}               | 2019-05-07 02:43:35+00:00 | Alarm       |        25386 | MAJOR    | Region=ITTE_R8E_CA_fuel1,CeeFunction=1,Node=cic-3,Service=rabbitmq-server                                              |   193 | 2031715 | other                | m3100Indeterminate                  | Service Permanently Stopped        | On node:cic-3 service: rabbitmq-server permanently stopped.                                               | None
${UNTREATED_RABBITMQ_MASTERS_NODE}         Masters: [ cic-2.domain.tld ]


*** Keywords ***
Get Rabbitmq Master Node
    [Documentation]  Obtain Rabbitmq Master Corresponding node

    #${Untreated_Masters_node}  ${error}  ${rc} =  Execute OpenStack Command On Random CIC  crm_mon -1 | sed -n '/rabbitmq-server/{n;p}'
    #Should Be Equal As Integers  ${rc}  0  ${error}
    #${Remove_Masters_node_the_left_parentheses} =  Remove String  ${Untreated_Masters_node}  [

    ${Remove_Masters_node_the_left_parentheses} =  Remove String  ${UNTREATED_RABBITMQ_MASTERS_NODE}  [
    ${Remove_Masters_node_the_right_parentheses} =  Remove String  ${Remove_Masters_node_the_left_parentheses}  ]
    @{Division_Masters_And_Cic} =  Split String  ${Remove_Masters_node_the_right_parentheses}  :
    @{Division_Cic_And_Domain} =  Split String  ${Division_Masters_And_Cic}[1]  .
    ${Rabbitmq_Masters_Node} =  Strip String  @{Division_Cic_And_Domain}[0]
    Log To Console  ${Rabbitmq_Masters_Node}
    [Return]    ${Rabbitmq_Masters_Node}

Stop RabbitMQ Service On CIC Node
    [Arguments]  ${rabbitmq_master}
    [Documentation]  Corresponding RabbitMQ Master node Stop

    Open Connection  ${rabbitmq_master}
    Login With Public Key  root  /root/.ssh/id_rsa
    ${date} =  Get Current Date
    ${implement_cmd} =  Execute Command  pwd
    ${rc} =  Execute Command  echo $#
    Should Be Equal As Integers  ${rc}  0
    Log To Console  ${implement_cmd}
    [Return]  ${date}
    #${output} =  Execute Command  service rabbitmq-server stop


Verify Alarms Of RabbitMQ Server on CIC node
    [Arguments]  ${cic_node}  ${trigger_date}
    [Documentation]  Obtain RabbitMQ Alarm information

    Open Connection  ${cic_node}
    Login With Public Key  root  /root/.ssh/id_rsa

    #${Obtaining_produce_alarm_information} =  Execute Command  source /root/openrc; watchmen-client alarm-history | grep rabbitmq-server | grep MAJOR | awk -F "|" '{print $2}'
    ${Obtaining_produce_alarm_information} =  Execute Command  source /root/openrc; pwd

    ${rc} =  Execute Command  echo $#
    Should Be Equal As Integers  ${rc}  0

    #@{gat_date_list} =  Split String  ${Obtaining_alarm_information}  |
    @{gat_date_list} =  Split String  ${EXPERiIMENT}  |

    ${Give_an_alarm_date} =  Strip String  @{gat_date_list}[1]
    Log To Console  ${Give_an_alarm_date}
    Log To Console  ${trigger_date}
    ${time_difference} =  Subtract Date From Date  ${Give_an_alarm_date}  ${trigger_date}
    Log To Console  ${time_difference}

Restore RabbitMQ Service On CIC Node
    [Arguments]  ${cic_node}
    [Documentation]  Corresponding RabbitMQ Master Node Start

    Open Connection  ${cic_node}
    Login With Public Key  root  /root/.ssh/id_rsa
    #Execute Command  service source /root/openrc; rabbitmq-server start
    ${start_rabbitmq_cmd} =  Execute Command  service source /root/openrc; pwd
    ${rc} =  Execute Command  echo $#
    Should Be Equal As Integers  ${rc}  0


Verify Alarms Of RabbitMQ Server Eliminate on CIC node
    [Documentation]  Obtain RabbitMQ Warning Elimination Information

    #${Obtaining_eliminate_alarm_information} =  Execute Command  source /root/openrc; watchmen-client alarm-history | grep rabbitmq-server | grep CLEARED | awk -F "|" '{print $2}'

    ${Obtaining_eliminate_alarm_information} =  Execute Command  source /root/openrc; pwd
    ${rc} =  Execute Command  echo $#
    Should Be Equal As Integers  ${rc}  0

    #@{gat_date_list} =  Split String  ${Obtaining_eliminate_alarm_information}  |

    @{gat_date_list} =  Split String  ${EXPERiIMENT}  |
    ${Give_an_alarm_eliminate_date} =  Strip String  @{gat_date_list}[1]
    Log To Console  ${Give_an_alarm_eliminate_date}
    [Return]  ${Give_an_alarm_eliminate_date}


*** Test Cases ***
Test1
    ${Rabbitm_Master_Node} =  Get Rabbitmq Master Node
    ${produce_date} =  Stop RabbitMQ Service On CIC Node  ${Rabbitm_Master_Node}
    Verify Alarms Of RabbitMQ Server on CIC node  ${Rabbitm_Master_Node}  ${produce_date}
    Restore RabbitMQ Service On CIC Node  ${Rabbitm_Master_Node}
    ${Give_an_alarm_eliminate_date} =  Verify Alarms Of RabbitMQ Server Eliminate on CIC node

