import QtQuick 2.15
import QtQuick.Controls 2.15
import "../theScripts/alltasks.js" as AllTasks
import "../theScripts/config.js" as Configs
import "../theScripts/completedtasks.js" as AddToCompletedTasks
import "../theScripts/todaytasks.js" as AddToTodayTask
import "../theComponents"

import "../theScripts/steptasks.js" as StepTaskManager

//                        var rs = tx.executeSql('SELECT * FROM '+DBC.table_allTasks+' INNER JOIN '+DBC.table_taskSteps+' ON '+DBC.table_allTasks+'.t_id='+DBC.table_taskSteps+'.t_id WHERE '+DBC.table_allTasks+'.t_id NOT IN (SELECT t_id FROM '+DBC.table_completedTasks+') AND '+DBC.table_allTasks+'.t_id NOT IN (SELECT t_id FROM '+DBC.table_todayTasks+') ORDER BY t_creationDate DESC;');

import QtQuick.Dialogs
Item
{
    property int selectedIdToDelete : 0;
    property string statusRemoveConfirmMessage : "wait";
    onStatusRemoveConfirmMessageChanged:
    {
        if(statusRemoveConfirmMessage=="confirmed")
        {
            const res = AllTasks.deleteTask(selectedIdToDelete);
            if(res)
            {
                console.log("source : AllTasks.qml -> i confirm the task is completely removed.");
                reloadAllTasks();
            }
            else
                console.log("source : AllTasks.qml -> something went wrong error="+res)
            baseConfirmYesOrNo.visible=false;

        }
        if(statusRemoveConfirmMessage=="canceled")
        {
            baseConfirmYesOrNo.visible=false;
        }
    }


    signal openTheSetupTaskForm;
    signal openTheModifyTaskForm(int id, string title, string desc, string timeToPerform, string creationDate, string priority,string deadline);

    onOpenTheSetupTaskForm:
    {
        console.log("source : AllTasks.qml -> signal openTheSetupTaskForm called.")
    }

    onOpenTheModifyTaskForm:
    {
        console.log("source : AllTasks.qml -> signal openTheModifyTaskForm called.");
    }

    signal reloadAllTasks;
    onReloadAllTasks:
    {
//        console.log("source: AllTasks.qml -> signal reloadAllTasks -> result Alltasks.getlist() -> " +AllTasks.getList());
        console.log("source : AllTasks.qml -> signal reloadAllTasks called.");
        listModelMain.clear();
        AllTasks.getList(listModelMain,"appendToList");
    }

    anchors.fill:parent;
    Component.onCompleted:
    {
        console.log("source : AllTasks.qml -> im completelly loaded.");
        reloadAllTasks();
    }



    Rectangle
    {
        id:theListBase;
        anchors
        {
            left:parent.left;
            right:parent.right;
            top:parent.top;
            bottom:addNewQuickTask.top;
        }
        color:"transparent";

        ListView
        {
            id:listViewMain;
            anchors.fill:parent;
//            anchors.topMargin:35;
            clip:true;
            header: Item
            {
                id:searchBar;
                width:parent.width;
                height: 60;
                //search input;
                Rectangle
                {
                    width:parent.width;
                    height:parent.height/1.5;
                    anchors.verticalCenter: parent.verticalCenter
                    color:"transparent";
                    TextField
                    {
                        id:searchWord;
                        anchors.fill:parent;
//                        onFocusChanged:
//                        {
//                            console.log("source : AllTasks.qml -> searchBar -> focus changed lets re-focuse on searchbar")
//                            searchWord.focus=true;
//                        }

                        onTextChanged:
                        {
                            //run search query
                            if(text!=="")
                            {
                                listModelMain.clear();
//                                AllTasks.searchTask(searchWord.text,listModelMain,"appendToList"); //search like off.
                                AllTasks.searchTask(searchWord.text,listModelMain,"appendToList",0); //search like on.
                            }
                            else
                            {
                                reloadAllTasks();
                            }

                        }
                    }
                }
            }
            model:
            ListModel
            {
                id:listModelMain;

            }
            delegate:
            Item
            {
                width: listViewMain.width;
                height: tsId> 0 ? 35:70;
                Rectangle
                {
                    anchors.fill: parent;

                    color:"transparent";
                    Rectangle
                    {
                        id:itemmm2;
                        width: tsId > 0 ? parent.width/1.50 : parent.width/1.10;
                        height: tsId > 0 ? parent.height/1.50 : 50; //tsId >0 means this is task Step. not a task
                        color: tsId > 0 ? "gold" : "gray"; //tsId >0 means this is task Step. not a task
                        radius:15;
                        anchors.horizontalCenter: parent.horizontalCenter;



                        MouseArea
                        {
                            anchors.fill:parent;
                            onPressAndHold:
                            {
                                console.log("source : AllTasks.qml ->  on task press and hold, details are: id="+tId + " title="+tTitle + "desc="+tDesc + " timetoperform="+tTimerToPerForm+ " deadlione"+tDeadline + " creation="+tCreation + " priority="+tPriority);
                                if(tId>0 && tsId===0)
                                    openTheModifyTaskForm(tId,tTitle,tDesc,tTimerToPerForm,tCreation,tPriority,tDeadline);
                                else
                                    console.log("soruce : AllTasks.qml -> this is not task, wait for new updates to be able modify stepTasks. task Step Id="+tsId);
//                              openTheSetupTaskForm(tId,tTitle,tDesc,tTimerToPerForm,tCreation,tPriority,tDeadline);
                            }
                            onClicked:
                            {
                                if(tsId === 0)
                                {
                                    console.log("source: AllTasks.qml -> on task clicked, lets add new step to this task");
                                    quicklyAddStep.visible=true;
                                }
                                else
                                    console.log("source: AllTasks.qml -> on stepTask can not add step task.");
                            }
                        }

                        Text
                        {
                            text: tsId>0 ? tsTitle : tTitle;
                            color: tsId > 0 ? "black":"white";
                            font.pointSize: tsId>0 ? 10 : 18;
                            width:parent.width/3;
                            clip:true;
                            anchors
                            {
                                verticalCenter:parent.verticalCenter;
                                left:parent.left;
                                leftMargin: 30;
                            }

                        }
                        Rectangle
                        {
                            id:todayButton;
                            width:tsId>0 ? 0: 45;
                            height:tsId> 0 ? 0 : parent.height;
                            visible: tsId>0? false:true;
                            anchors.right:parent.right;
                            color:"transparent";
                            Image
                            {
                                source: Configs.icon_addTodayTask;
                                anchors.centerIn: parent;
                            }

                            MouseArea
                            {
                                anchors.fill:parent;
                                onClicked:
                                {
                                    console.log("source : AllTasks.qml -> add to today this task clicked, id="+tId);
                                    const res = AddToTodayTask.addTaskToToday(tId);
                                    if(res)
                                    {
                                        console.log("source : AllTasks.qml -> i confirm the task is completely adde to today task.");
                                        reloadAllTasks();
                                    }
                                    else
                                        console.log("source : AllTasks.qml -> something went wrong error="+res)
                                }
                            }
                        }

                        Rectangle
                        {
                            id:completeButton;
                            width:45;
                            height:parent.height;
                            anchors.right:todayButton.left;
                            color:"transparent";
                            Image
                            {
                                source: Configs.icon_completeTasks;
                                anchors.centerIn: parent;
                            }

                            MouseArea
                            {
                                anchors.fill:parent;
                                onClicked:
                                {
                                    if(tsId>0)
                                    {
                                        console.log("source : AllTasks.qml -> complete this step task clicked, tasKStepId="+tsId);
                                        StepTaskManager.
                                    }
                                    else
                                    {
                                        console.log("source : AllTasks.qml -> complete this task clicked, id="+tId);
                                        const res = AddToCompletedTasks.completeTask(tId);
                                        if(res)
                                        {
                                            console.log("source : AllTasks.qml -> i confirm the task is completely completed.");
                                            reloadAllTasks();
                                        }
                                        else
                                            console.log("source : AllTasks.qml -> something went wrong error="+res)
                                    }
                                }
                            }
                        }


                        Rectangle
                        {
                            id:removeButton;
                            width:45;
                            height:parent.height;
                            anchors.right:completeButton.left;
                            color:"transparent";
                            Image
                            {
                                source: Configs.icon_removeTasks;
                                anchors.centerIn: parent;
                            }

                            MouseArea
                            {
                                anchors.fill:parent;


                                onClicked:
                                {
                                    console.log("source : AllTasks.qml -> remove task clicekd, id="+tId);
                                    baseConfirmYesOrNo.visible=true;
                                    confirmMessage.textMessage = "are you sure to delete ("+tTitle+") ?";
                                    selectedIdToDelete=tId;
                                    confirmMessage.response="wait"
                                }

                            }
                        }

                        QuicklySetupTaskStep
                        {
                            id:quicklyAddStep;
                            visible:false;
                            setTaskId: tId;
                        }




                    }


                }

            }//end of item delegate

        }//end of list view


    }

    Rectangle
    {
        id:addNewQuickTask;
        width:parent.width;
        height:45;
        color:"transparent";
        anchors.bottom:parent.bottom;
        Row
        {
            anchors.fill:parent;
            TextField
            {
                id:taskTitle;
                width:parent.width-40;
                height:parent.height;
                wrapMode: "WrapAnywhere"
                maximumLength: 40;
            }
            Rectangle
            {
//                anchors.right:parent.right;
                color:"gray";
                width:40;
                height:parent.height;
                Image
                {
                    anchors.centerIn:parent;
                    source: taskTitle.length>0 ? Configs.icon_submitTasks : Configs.icon_addTasks;
                }

                MouseArea
                {
                    anchors.fill:parent;
                    onClicked:
                    {
                        console.log("source : AllTasks.qml -> on submit new task button clicked.");
                        if(taskTitle.text==="")
                        {
                            console.log("source: allTasks.qml -> add new task via setup and form.");
                            openTheSetupTaskForm();
                        }
                        else
                        {
                            const res=  AllTasks.addQuicklyNewTask(taskTitle.text);
                            if(res)
                            {
                                console.log("source : AllTasks.qml -> response is ok query submitted as QuickTask.");
                                taskTitle.clear();
                                reloadAllTasks();
                            }
                        }
                    }
                }
            }
        }

    }



    Rectangle
    {
        id:baseConfirmYesOrNo;
        anchors.fill: parent;
        color:"black";
        opacity: 0.6;
        visible: false;

        MouseArea
        {
            anchors.fill: parent;
            onClicked:
            {
                confirmMessage.response="canceled";
            }
        }
        ConfirmYesOrNo
        {
            id:confirmMessage;
            onResponseChanged:
            {
                statusRemoveConfirmMessage=response;
            }
        }
    }



}
